import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_RECIPES } from "../../constants/rs3-paths";
import { PageTags } from "../../constants/tags";
import { Recipe } from "../../types";
import { parseRecipeProperties } from "../../modules/extractors/recipes.extractor";
import { parseWikitext } from "../../utils/wikitext-parser";
import { Rs3ItemsExtractor } from "./rs3-items.extractor";
import { Rs3SetsExtractor } from "./rs3-sets.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/**
 * Normalises an RS3 `{{Infobox Recipe}}` template record into the shape that
 * the OSRS {@link parseRecipeProperties} expects.
 *
 * The two wikis use almost identical parameter structures (skill1, mat1,
 * output1, …) but diverge on a handful of names. This function renames the
 * RS3 variants to their OSRS equivalents so the same parser handles both:
 *
 * | RS3 param            | OSRS param            | Why                          |
 * | -------------------- | --------------------- | ---------------------------- |
 * | `mat{n}qty`          | `mat{n}quantity`      | abbreviation                 |
 * | `output{n}qty`       | `output{n}quantity`   | abbreviation                 |
 * | `tool`               | `tools`               | singular → plural            |
 * | `facility`           | `facilities`          | singular → plural            |
 * | `mat{n}pnote`        | `mat{n}itemnote`      | "price note" → "item note"   |
 *
 * RS3-only fields (`mat{n}img`, `mat{n}name`, `method`, `improved`,
 * `process`, `quest`, `misc{n}`, `instructions`, `ticks2`, `smw`,
 * `totalvar`, `output{n}img`, `output{n}cost`) are dropped — the OSRS
 * `Recipe` type has no slot for them.
 *
 * Exported for unit testing.
 */
export function normalizeRs3RecipeKeys(
  raw: Record<string, string | boolean>,
): Record<string, string | boolean> {
  const out: Record<string, string | boolean> = {};
  for (const [key, value] of Object.entries(raw)) {
    let newKey = key;
    // mat3qty → mat3quantity, output1qty → output1quantity
    newKey = newKey.replace(/^(mat|output)(\d+)qty$/, "$1$2quantity");
    // mat5pnote → mat5itemnote
    newKey = newKey.replace(/^(mat)(\d+)pnote$/, "$1$2itemnote");
    // Singular facility/tool at the top level → plural (OSRS form)
    if (newKey === "facility") newKey = "facilities";
    if (newKey === "tool") newKey = "tools";
    out[newKey] = value;
  }
  return out;
}

/**
 * RS3 counterpart of {@link RecipesExtractor}.
 *
 * RS3 stores recipes on item pages via `{{Infobox Recipe|...}}` (OSRS uses
 * `{{Recipe|...}}` on dedicated skill pages). Parameter shapes are similar
 * enough that we delegate to the OSRS pure parser after a key-renormalisation
 * pass; see {@link normalizeRs3RecipeKeys}.
 */
@Injectable()
export class Rs3RecipesExtractor {
  private logger: Logger = new Logger(Rs3RecipesExtractor.name);
  private cachedRecipes: Recipe[] | null = null;

  constructor(
    private itemExtractor: Rs3ItemsExtractor,
    private setsExtractor: Rs3SetsExtractor,
    private pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllRecipes() {
    this.logger.log("Starting to extract recipes (RS3)");

    // Recipes on RS3 live both on item pages (most common) and on dedicated
    // recipe pages. Scan ITEM-tagged + RECIPE-tagged pages, deduped.
    const [itemPages, recipePages] = await Promise.all([
      this.pageListDumper.getPagesFromTag(PageTags.ITEM),
      this.pageListDumper.getPagesFromTag(PageTags.RECIPE),
    ]);
    const seenPageIds = new Set<number>();
    const pagesToScan = [...itemPages, ...recipePages].filter((page) => {
      if (seenPageIds.has(page.id)) return false;
      seenPageIds.add(page.id);
      return true;
    });

    const recipes: Recipe[] = [];
    for await (const page of pagesToScan) {
      const pageRecipes = await this.extractRecipesFromPageId(page.id);
      if (pageRecipes === null) {
        continue;
      }
      recipes.push(...pageRecipes);
    }

    // Add set decomposition recipes (same pattern as OSRS).
    const sets = await this.setsExtractor.getAllSets();
    if (sets !== null) {
      sets
        .filter((s) => s.id)
        .map((set) => {
          const setItem = this.itemExtractor.getItemById(set.id);
          const makeRecipe: Recipe = {
            name: `Making ${setItem?.name || "Unknown set"}`,
            inputs: set.componentIds.map((v) => ({ id: v, quantity: 1 })),
            outputs: [{ id: set.id, quantity: 1 }],
            skills: [],
            members: setItem?.isMembers || false,
            ticks: 1,
            toolIds: [],
          };
          const breakRecipe: Recipe = {
            outputs: set.componentIds.map((v) => ({ id: v, quantity: 1 })),
            inputs: [{ id: set.id, quantity: 1 }],
            skills: [],
            members: true,
            ticks: 1,
            toolIds: [],
          };
          return [makeRecipe, breakRecipe];
        })
        .forEach((setRecipes) => {
          recipes.push(...setRecipes);
        });
    }

    if (recipes.length) {
      recipes.sort((a, b) => a?.name?.localeCompare(b.name || "") || 0);
      writeFileSync(ALL_RECIPES, JSON.stringify(recipes));
    }

    this.logger.log(`End of recipes extraction (RS3) — ${recipes.length} recipes`);
    return recipes;
  }

  public getAllRecipes(): Recipe[] | null {
    if (!this.cachedRecipes) {
      const candidatePath = ALL_RECIPES;
      if (!existsSync(candidatePath)) {
        return null;
      }
      const pageContent = readFileSync(candidatePath, "utf8");
      try {
        this.cachedRecipes = JSON.parse(pageContent);
      } catch (e) {
        this.logger.warn("all recipes has invalid content", e);
      }
    }
    return this.cachedRecipes;
  }

  private async extractRecipesFromPageId(pageId: number): Promise<Recipe[] | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);

    // Substring check covers `{{Infobox Recipe` and any future variant.
    // Lowercase compare so `{{infobox recipe` matches too.
    if (!page?.text || !page.text.toLowerCase().includes("{{infobox recipe")) {
      return null;
    }

    // wtf_wikipedia strips the "Infobox " prefix, so `getTemplates` can't
    // find these — use `getAllInfoboxes` filtered by type. This also lets
    // us pick up pages with multiple recipes (e.g. different skill methods).
    const tfPage = parseWikitext(page.text);
    const recipeTemplates = tfPage
      .getAllInfoboxes()
      .filter((box) => box.type === "recipe")
      .map((box) => box.data as Record<string, string | boolean>);

    return recipeTemplates
      .map((raw) => {
        const normalized = normalizeRs3RecipeKeys(raw);
        // OSRS parser expects a synthetic `name` field for the recipe — derive
        // one from the page title so consumers see something meaningful.
        if (!normalized.name) {
          normalized.name = `Making ${page.title}`;
        }
        return parseRecipeProperties(normalized, (name) =>
          this.itemExtractor.getItemByName(name),
        );
      })
      .filter((v): v is Recipe => v !== null);
  }
}
