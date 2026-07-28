import { describe, expect, it } from "vitest";
import { parseWikitext } from "../../utils/wikitext-parser";
import { parseRecipeProperties } from "../../modules/extractors/recipes.extractor";
import { normalizeRs3RecipeKeys } from "./rs3-recipes.extractor";

// Black dragonhide vambraces — real RS3 page content (truncated to the
// recipe-relevant parts). Source: https://runescape.wiki/w/Black_dragonhide_vambraces
const BLACK_DHIDE_VAMBRACES_TEXT = `
{{Infobox Item
|name = Black dragonhide vambraces
|id = 2491
}}

Some flavour text here.

==Creation==
{{Infobox Recipe
|members = Yes
|ticks = 3
|tool = Needle
|skill1 = Crafting
|skill1lvl = 60
|skill1boostable = Yes
|skill1exp = 86
|mat1 = Thread
|mat1qty = 0.2
|mat2 = Black dragon leather
|output1 = Black dragonhide vambraces
}}

More content.
`;

// Item name → id lookup mirroring what the extractor builds from the items JSON.
const itemIds: Record<string, number> = {
  Thread: 1734,
  "Black dragon leather": 2507,
  "Black dragonhide vambraces": 2491,
  Needle: 1733,
};
const lookup = (name: string) =>
  itemIds[name] ? { id: itemIds[name] } : null;

function extractRs3RecipeTemplates(text: string) {
  return parseWikitext(text)
    .getAllInfoboxes()
    .filter((box) => box.type === "recipe")
    .map((box) => box.data as Record<string, string | boolean>);
}

describe("normalizeRs3RecipeKeys", () => {
  it("renames mat{n}qty → mat{n}quantity", () => {
    const out = normalizeRs3RecipeKeys({ mat1qty: "5", mat2qty: "10" });
    expect(out).toEqual({ mat1quantity: "5", mat2quantity: "10" });
  });

  it("renames output{n}qty → output{n}quantity", () => {
    const out = normalizeRs3RecipeKeys({ output1qty: "1", output2qty: "15" });
    expect(out).toEqual({ output1quantity: "1", output2quantity: "15" });
  });

  it("renames mat{n}pnote → mat{n}itemnote", () => {
    const out = normalizeRs3RecipeKeys({ mat3pnote: "Some note" });
    expect(out).toEqual({ mat3itemnote: "Some note" });
  });

  it("renames singular tool/facility → plural", () => {
    const out = normalizeRs3RecipeKeys({ tool: "Needle", facility: "Furnace" });
    expect(out).toEqual({ tools: "Needle", facilities: "Furnace" });
  });

  it("passes through unrelated keys unchanged", () => {
    const out = normalizeRs3RecipeKeys({
      members: "Yes",
      skill1: "Crafting",
      mat1: "Thread",
      ticks: "3",
    });
    expect(out).toEqual({
      members: "Yes",
      skill1: "Crafting",
      mat1: "Thread",
      ticks: "3",
    });
  });
});

describe("Rs3RecipesExtractor — end-to-end parse", () => {
  it("parses the Black dragonhide vambraces Infobox Recipe correctly", () => {
    const templates = extractRs3RecipeTemplates(BLACK_DHIDE_VAMBRACES_TEXT);
    expect(templates).toHaveLength(1);

    const normalized = normalizeRs3RecipeKeys(templates[0]);
    const recipe = parseRecipeProperties(normalized, lookup);

    expect(recipe).not.toBeNull();
    expect(recipe!.members).toBe(true);
    expect(recipe!.ticks).toBe(3);
    // `tool = Needle` was normalised to `tools`, then the OSRS parser
    // resolved it against the item lookup → toolIds.
    expect(recipe!.toolIds).toEqual([1733]);
    // No `facility` in the source wikitext → field is unset.
    expect(recipe!.facility).toBeUndefined();

    // Skills
    expect(recipe!.skills).toHaveLength(1);
    expect(recipe!.skills[0].name).toBe("Crafting");
    expect(recipe!.skills[0].lvl).toBe(60);
    expect(recipe!.skills[0].boostable).toBe(true);
    expect(recipe!.skills[0].xp).toBe(86);

    // Materials (inputs)
    expect(recipe!.inputs).toHaveLength(2);
    const [thread, leather] = recipe!.inputs;
    expect(thread.id).toBe(1734);
    expect(thread.quantity).toBeCloseTo(0.2, 5);
    expect(leather.id).toBe(2507);
    expect(leather.quantity).toBe(1); // default

    // Output
    expect(recipe!.outputs).toHaveLength(1);
    expect(recipe!.outputs[0].id).toBe(2491);
    expect(recipe!.outputs[0].quantity).toBe(1);
  });

  it("returns no recipes from a page that doesn't transclude Infobox Recipe", () => {
    const text = "Just some wikitext with no recipe template.";
    expect(extractRs3RecipeTemplates(text)).toHaveLength(0);
  });

  it("does NOT pick up {{Recipe}} (OSRS-style) templates on RS3 pages", () => {
    const text = "{{Recipe|skill1=Crafting|output1=Foo}}";
    expect(extractRs3RecipeTemplates(text)).toHaveLength(0);
  });
});
