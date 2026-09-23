import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync } from "fs";
import { safeWriteFileSync } from "../../utils/safe-write";
import { ALL_SKILL_RESOURCES } from "../../constants/paths";
import { SKILL_DROP_LINE_TEMPLATE_NAMES, SKILL_INFO_TEMPLATE_NAMES } from "../../constants/skills";
import { PageTags } from "../../constants/tags";
import { SkillResource, SkillResourceDrop, SkillResourceVariant } from "../../types";
import { parseWikitext } from "../../utils/wikitext-parser";
import { wikiNumber, wikiString } from "../../utils/wiki-coercion";
import { PageContentDumper, PageListDumper } from "../dumpers";
import { ItemsExtractor } from "./items.extractor";

/** Highest variant suffix to scan for (version1..version12, level1..level12, ...). */
const MAX_VARIANTS = 12;

type InfoFields = Record<string, unknown>;

function optionalNumber(val: unknown): number | null {
  if (val === null || val === undefined || val === "") return null;
  return wikiNumber(val);
}

/**
 * Resolves the canonical skill for a generic `{{Skill info}}` transclusion
 * from its `skill1name` parameter. Per-skill wrappers carry the skill
 * implicitly in the template name instead.
 */
function skillFromGenericInfo(fields: InfoFields): string {
  return wikiString(fields.skill1name ?? fields.skill1name1 ?? "");
}

/**
 * Extracts numbered variants (`version1`/`name1`, `level1`, `xp1`, `tool1`,
 * `time1`, ... params) from an info template's fields.
 */
function extractVariants(fields: InfoFields): SkillResourceVariant[] {
  const variants: SkillResourceVariant[] = [];
  for (let i = 1; i <= MAX_VARIANTS; i++) {
    const label = wikiString(fields[`name${i}`] ?? fields[`version${i}`] ?? "");
    const level = optionalNumber(fields[`level${i}`]);
    const xp = optionalNumber(fields[`xp${i}`] ?? fields[`skill1exp${i}`]);
    const tool = wikiString(fields[`tool${i}`] ?? "");
    const time = wikiString(fields[`time${i}`] ?? "");
    if (!label && level === null && xp === null && !tool && !time) continue;
    variants.push({
      ...(label && { name: label }),
      ...(level !== null && { level }),
      ...(xp !== null && { xp }),
      ...(tool && { tool }),
      ...(time && { time }),
    });
  }
  return variants;
}

function parseDropsLineSkill(
  templates: Array<Record<string, unknown>>,
  skill: string,
  itemLookup: (name: string) => { id: number } | null,
): SkillResourceDrop[] {
  return templates
    .map((t) => {
      const name = wikiString(t.name);
      // A page can host drop rows for several skills (e.g. a tree with both
      // Woodcutting and Forestry rows); only keep the matching ones. Rows
      // without a skill param are assumed to belong to the page's skill.
      const rowSkill = wikiString(t.skill);
      if (rowSkill && rowSkill.toLowerCase() !== skill.toLowerCase()) {
        return null;
      }
      if (!name) return null;
      return {
        name,
        itemId: itemLookup(name)?.id ?? null,
        quantity: wikiString(t.quantity),
        rarity: wikiString(t.rarity),
        altRarity: wikiString(t.altrarity),
        rarityNotes: wikiString(t.raritynotes),
      } satisfies SkillResourceDrop;
    })
    .filter((d): d is SkillResourceDrop => d !== null);
}

/**
 * Collects a resource's drop rows from the page's parsed templates.
 *
 * Two wiki conventions are supported:
 * - OSRS: `{{DropsLineSkill|...|skill=<Skill>}}`, filtered by the row's
 *   `skill` param (rows without one are kept — the page's skill is implied).
 * - RS3: skill-suffixed variants like `{{DropsLineWC|...}}`, selected via
 *   {@link SKILL_DROP_LINE_TEMPLATE_NAMES} (the skill is the suffix).
 */
function collectDrops(
  parsed: ReturnType<typeof parseWikitext>,
  skill: string,
  itemLookup: (name: string) => { id: number } | null,
): SkillResourceDrop[] {
  const drops = parseDropsLineSkill(parsed.getTemplates("dropslineskill"), skill, itemLookup);
  const suffixTemplates = SKILL_DROP_LINE_TEMPLATE_NAMES[skill] ?? [];
  for (const templateName of suffixTemplates) {
    drops.push(
      ...parsed
        .getTemplates(templateName)
        .map((t) => {
          const name = wikiString(t.name);
          if (!name) return null;
          return {
            name,
            itemId: itemLookup(name)?.id ?? null,
            quantity: wikiString(t.quantity),
            rarity: wikiString(t.rarity),
            altRarity: wikiString(t.altrarity),
            rarityNotes: wikiString(t.raritynotes),
          } satisfies SkillResourceDrop;
        })
        .filter((d): d is SkillResourceDrop => d !== null),
    );
  }
  return drops;
}

/**
 * Parses every `{{<Skill> info}}` template on a page into a
 * {@link SkillResource}, joining in the page's skilling drop rows.
 *
 * The info template is what identifies the page as a skill resource (it is
 * the data source behind the wiki's skill experience tables); the drops are
 * the skilling equivalent of a monster's drop table — `{{DropsLineSkill}}`
 * rows on the OSRS wiki, skill-suffixed `{{DropsLineWC}}`-style variants on
 * the RS3 wiki (see {@link collectDrops}).
 */
export function parseSkillResourceFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[],
  itemLookup: (name: string) => { id: number } | null,
): SkillResource[] {
  const parsed = parseWikitext(pageText);

  const resources: SkillResource[] = [];
  for (const [templateName, canonicalSkill] of Object.entries(SKILL_INFO_TEMPLATE_NAMES)) {
    for (const fields of parsed.getTemplates(templateName)) {
      const skill = canonicalSkill ?? skillFromGenericInfo(fields);
      if (!skill) continue;

      resources.push({
        name: wikiString(fields.name) || pageTitle,
        skill,
        aliases: pageAliases,
        level: optionalNumber(fields.level ?? fields.skill1lvl),
        xp: optionalNumber(fields.xp ?? fields.skill1exp),
        tool: wikiString(fields.tool),
        time: wikiString(fields.time),
        variants: extractVariants(fields),
        drops: collectDrops(parsed, skill, itemLookup),
      });
    }
  }
  return resources;
}

@Injectable()
export class SkillResourcesExtractor {
  private logger = new Logger(SkillResourcesExtractor.name);
  private cachedSkillResources: SkillResource[] | null = null;

  constructor(
    private itemExtractor: ItemsExtractor,
    private pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
  ) {}

  public async extractAllSkillResources(): Promise<SkillResource[]> {
    this.logger.log("Start: Extracting skill resources");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.SKILL_RESOURCE);
    const length = pages.length;
    const skillResources: SkillResource[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Skill resources: ${i}/${length}`);
      }
      skillResources.push(...(await this.extractSkillResourcesFromPageId(page.id)));
    }

    skillResources.sort((a, b) => a.skill.localeCompare(b.skill) || a.name.localeCompare(b.name));
    if (skillResources.length) {
      await safeWriteFileSync(ALL_SKILL_RESOURCES, JSON.stringify(skillResources, null, 2));
    }

    this.logger.log("Done: Extracting skill resources");
    return skillResources;
  }

  public getAllSkillResources(): SkillResource[] | null {
    if (!this.cachedSkillResources) {
      if (!existsSync(ALL_SKILL_RESOURCES)) {
        return null;
      }
      try {
        this.cachedSkillResources = JSON.parse(readFileSync(ALL_SKILL_RESOURCES, "utf8"));
      } catch (e) {
        this.logger.warn("all skill resources has invalid content", e);
      }
    }
    return this.cachedSkillResources;
  }

  private async extractSkillResourcesFromPageId(pageId: number): Promise<SkillResource[]> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return [];
    }
    return parseSkillResourceFromContent(page.text, page.title, page.aliases || [], (name) =>
      this.itemExtractor.getItemByName(name),
    );
  }
}
