import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_NPCS } from '../../constants/paths';
import { NPC } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { PageTags } from '../../constants/tags';
import { parseWikitext } from '../../utils/wikitext-parser';
import { parseMapTemplate } from '../../utils/map-parser';
import { getVariantField, extractVariants } from '../../utils/variant-utils';
import {
  parseListValue,
  wikiBool,
  wikiNumber,
  wikiString,
} from '../../utils/wiki-coercion';

const NPC_FIELDS = [
  'id',
  'name',
  'members',
  'race',
  'location',
  'quest',
  'gender',
  'options',
  'examine',
  'leagueregion',
] as const;

function buildNpc(
  fields: Record<string, unknown>,
  pageTitle: string,
  pageAliases: string[],
  position?: { x: number; y: number }
): NPC | null {
  const id = wikiNumber(fields.id);
  if (!id) return null;

  const npc: NPC = {
    id,
    name: wikiString(fields.name) || pageTitle,
    aliases: pageAliases,
    members: wikiBool(fields.members),
    race: wikiString(fields.race),
    location: wikiString(fields.location),
    quest: wikiString(fields.quest),
    gender: wikiString(fields.gender),
    options: parseListValue(fields.options),
    examine: wikiString(fields.examine),
  };

  const leagueRegion = wikiString(fields.leagueregion);
  if (leagueRegion) npc.leagueRegion = leagueRegion;
  if (position) npc.position = position;

  return npc;
}

export function parseNpcFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[]
): NPC[] {
  const parsed = parseWikitext(pageText);
  const data = parsed.getInfobox('npc');
  if (!data) return [];

  let position: { x: number; y: number } | undefined;
  for (const mapTemplate of parsed.getTemplates('map')) {
    const map = parseMapTemplate(mapTemplate);
    if (map?.point) {
      position = map.point;
      break;
    }
  }

  const { hasVariants, variants, commonFields } = extractVariants(data);

  if (!hasVariants) {
    const npc = buildNpc(commonFields, pageTitle, pageAliases, position);
    return npc ? [npc] : [];
  }

  const npcs: NPC[] = [];
  for (const variant of variants) {
    const fields: Record<string, unknown> = {};
    for (const baseKey of NPC_FIELDS) {
      const value = getVariantField(variant.fields, commonFields, baseKey);
      if (value !== undefined) fields[baseKey] = value;
    }
    const npc = buildNpc(fields, pageTitle, pageAliases, position);
    if (npc) npcs.push(npc);
  }
  return npcs;
}

@Injectable()
export class NpcsExtractor {
  private logger = new Logger(NpcsExtractor.name);
  private cachedNpcs: NPC[] | null = null;

  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllNpcs(): Promise<NPC[]> {
    this.logger.log('Start: Extracting NPCs');

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.NPC);
    const length = pages.length;
    const npcs: NPC[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`NPCs: ${i}/${length}`);
      }
      npcs.push(...(await this.extractNpcFromPageId(page.id)));
    }

    npcs.sort((a, b) => a.name.localeCompare(b.name));
    if (npcs.length) {
      writeFileSync(ALL_NPCS, JSON.stringify(npcs, null, 2));
    }

    this.logger.log('Done: Extracting NPCs');
    return npcs;
  }

  public getAllNpcs(): NPC[] | null {
    if (!this.cachedNpcs) {
      if (!existsSync(ALL_NPCS)) {
        return null;
      }
      try {
        this.cachedNpcs = JSON.parse(readFileSync(ALL_NPCS, 'utf8'));
      } catch (e) {
        this.logger.warn('all npcs has invalid content', e);
      }
    }
    return this.cachedNpcs;
  }

  private async extractNpcFromPageId(pageId: number): Promise<NPC[]> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return [];
    }
    return parseNpcFromContent(page.text, page.title, page.aliases || []);
  }
}
