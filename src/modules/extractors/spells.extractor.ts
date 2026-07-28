import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_SPELLS } from "../../constants/paths";
import { RuneCost, Spell } from "../../types";
import { PageContentDumper, PageListDumper } from "../dumpers";
import { PageTags } from "../../constants/tags";
import { ItemsExtractor } from "./items.extractor";
import { parseWikitext } from "../../utils/wikitext-parser";
import { wikiBool, wikiNumber, wikiString } from "../../utils/wiki-coercion";

const IGNORED_RUNE_REQ_KEYS = new Set(["template", "name"]);

function toRuneItemName(key: string): string {
  const cased = `${key.charAt(0).toUpperCase()}${key.slice(1).toLowerCase()}`;
  return `${cased} rune`;
}

function parseRuneCosts(
  runeReqTemplates: Array<Record<string, unknown>>,
  itemLookup: (name: string) => { id: number } | null,
): RuneCost[] {
  const costs: RuneCost[] = [];
  for (const tmpl of runeReqTemplates) {
    for (const [key, value] of Object.entries(tmpl)) {
      if (IGNORED_RUNE_REQ_KEYS.has(key)) continue;
      const quantity = wikiNumber(value);
      if (!quantity) continue;
      const runeName = toRuneItemName(key);
      costs.push({
        itemId: itemLookup(runeName)?.id ?? null,
        quantity,
      });
    }
  }
  return costs;
}

function parseSpeed(value: unknown): number | undefined {
  if (value === null || value === undefined) return undefined;
  const match = String(value).match(/\d+/);
  return match ? Number(match[0]) : undefined;
}

export function parseSpellFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[],
  itemLookup: (name: string) => { id: number } | null,
): Spell | null {
  const parsed = parseWikitext(pageText);
  const data = parsed.getInfobox("spell");
  if (!data) return null;

  const runeReqTemplates = parsed.getTemplates("runereq");
  const runeCost = parseRuneCosts(runeReqTemplates, itemLookup);
  const speed = parseSpeed(data.speed);

  const spell: Spell = {
    name: wikiString(data.name) || pageTitle,
    aliases: pageAliases,
    level: wikiNumber(data.level),
    spellbook: wikiString(data.spellbook),
    type: wikiString(data.type),
    exp: wikiNumber(data.exp),
    members: wikiBool(data.members),
    description: wikiString(data.description),
    cost: wikiString(data.cost),
    runeCost,
  };

  if (data.element) spell.element = wikiString(data.element);
  if (data.damage) spell.damage = wikiString(data.damage);
  if (speed !== undefined) spell.speed = speed;
  if (data.image) spell.image = data.image;

  return spell;
}

@Injectable()
export class SpellsExtractor {
  private logger = new Logger(SpellsExtractor.name);
  private cachedSpells: Spell[] | null = null;

  constructor(
    private readonly itemExtractor: ItemsExtractor,
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
  ) {}

  public async extractAllSpells(): Promise<Spell[]> {
    this.logger.log("Start: Extracting spells");

    const spellPages = await this.pageListDumper.getPagesFromTag(PageTags.SPELL);
    const length = spellPages.length;
    const spells: Spell[] = [];
    let i = 0;
    for await (const page of spellPages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Spells: ${i}/${length}`);
      }
      const spell = await this.extractSpellFromPageId(page.id);
      if (spell) {
        spells.push(spell);
      }
    }

    spells.sort((a, b) => a.name.localeCompare(b.name));
    if (spells.length) {
      writeFileSync(ALL_SPELLS, JSON.stringify(spells, null, 2));
    }

    this.logger.log("Done: Extracting spells");
    return spells;
  }

  public getAllSpells(): Spell[] | null {
    if (!this.cachedSpells) {
      if (!existsSync(ALL_SPELLS)) {
        return null;
      }
      try {
        this.cachedSpells = JSON.parse(readFileSync(ALL_SPELLS, "utf8"));
      } catch (e) {
        this.logger.warn("all spells has invalid content", e);
      }
    }
    return this.cachedSpells;
  }

  private async extractSpellFromPageId(pageId: number): Promise<Spell | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    const lookup = (name: string) => this.itemExtractor.getItemByName(name) ?? null;
    return parseSpellFromContent(page.text, page.title, page.aliases || [], lookup);
  }
}
