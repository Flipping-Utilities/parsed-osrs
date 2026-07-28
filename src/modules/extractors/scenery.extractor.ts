import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_SCENERY } from "../../constants/paths";
import { Scenery } from "../../types";
import { PageContentDumper, PageListDumper } from "../dumpers";
import { PageTags } from "../../constants/tags";
import { parseWikitext } from "../../utils/wikitext-parser";
import { getVariantField, extractVariants } from "../../utils/variant-utils";
import { parseListValue, wikiString } from "../../utils/wiki-coercion";

const SCENERY_FIELDS = [
  "name",
  "id",
  "members",
  "quest",
  "location",
  "options",
  "examine",
] as const;

function parseSceneryMembers(val: unknown): boolean | null {
  const lower = String(val ?? "")
    .toLowerCase()
    .trim();
  if (lower === "yes") return true;
  if (lower === "no") return false;
  return null;
}

function buildScenery(
  fields: Record<string, unknown>,
  pageTitle: string,
  pageAliases: string[],
): Scenery | null {
  const idRaw = wikiString(fields.id);
  if (!idRaw || idRaw.toLowerCase() === "no") return null;

  const ids = idRaw
    .split(",")
    .map((s) => Number(s.trim()))
    .filter((n) => Number.isFinite(n) && n > 0);
  if (!ids.length) return null;

  return {
    id: ids[0],
    ids,
    name: wikiString(fields.name) || pageTitle,
    aliases: pageAliases,
    members: parseSceneryMembers(fields.members),
    quest: wikiString(fields.quest),
    location: wikiString(fields.location),
    options: parseListValue(fields.options),
    examine: wikiString(fields.examine),
  };
}

export function parseSceneryFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[],
): Scenery[] {
  const parsed = parseWikitext(pageText);
  const data = parsed.getInfobox("scenery");
  if (!data) return [];

  const { hasVariants, variants, commonFields } = extractVariants(data);

  if (!hasVariants) {
    const scenery = buildScenery(commonFields, pageTitle, pageAliases);
    return scenery ? [scenery] : [];
  }

  const result: Scenery[] = [];
  for (const variant of variants) {
    const fields: Record<string, unknown> = {};
    for (const baseKey of SCENERY_FIELDS) {
      const value = getVariantField(variant.fields, commonFields, baseKey);
      if (value !== undefined) fields[baseKey] = value;
    }
    const scenery = buildScenery(fields, pageTitle, pageAliases);
    if (scenery) result.push(scenery);
  }
  return result;
}

@Injectable()
export class SceneryExtractor {
  private logger = new Logger(SceneryExtractor.name);
  private cachedScenery: Scenery[] | null = null;

  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
  ) {}

  public async extractAllScenery(): Promise<Scenery[]> {
    this.logger.log("Start: Extracting scenery");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.SCENERY);
    const length = pages.length;
    const scenery: Scenery[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Scenery: ${i}/${length}`);
      }
      scenery.push(...(await this.extractSceneryFromPageId(page.id)));
    }

    scenery.sort((a, b) => a.name.localeCompare(b.name));
    if (scenery.length) {
      writeFileSync(ALL_SCENERY, JSON.stringify(scenery, null, 2));
    }

    this.logger.log("Done: Extracting scenery");
    return scenery;
  }

  public getAllScenery(): Scenery[] | null {
    if (!this.cachedScenery) {
      if (!existsSync(ALL_SCENERY)) {
        return null;
      }
      try {
        this.cachedScenery = JSON.parse(readFileSync(ALL_SCENERY, "utf8"));
      } catch (e) {
        this.logger.warn("all scenery has invalid content", e);
      }
    }
    return this.cachedScenery;
  }

  private async extractSceneryFromPageId(pageId: number): Promise<Scenery[]> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return [];
    }
    return parseSceneryFromContent(page.text, page.title, page.aliases || []);
  }
}
