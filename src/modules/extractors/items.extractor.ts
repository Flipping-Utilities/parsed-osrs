import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { load } from 'cheerio';
import { ALL_ITEMS } from '../../constants/paths';
import { EquipmentStats, Item } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { WikiRequestService } from '../wiki/wikiRequest.service';
import { parseWikitext } from '../../utils/wikitext-parser';
import {
  parseListValue,
  wikiBool,
  wikiNumber,
  wikiString,
} from '../../utils/wiki-coercion';

const GELimitsModulePath = '/w/Module:GELimits/data.json';

const STRING_STAT_KEYS = new Set<keyof EquipmentStats>(['slot', 'combatStyle']);

const WikiToEquipmentStatsKeys: Record<string, keyof EquipmentStats> = {
  astab: 'attackStab',
  aslash: 'attackSlash',
  acrush: 'attackCrush',
  amagic: 'attackMagic',
  arange: 'attackRanged',
  dstab: 'defendStab',
  dslash: 'defendSlash',
  dcrush: 'defendCrush',
  dmagic: 'defendMagic',
  drange: 'defendRanged',
  str: 'strength',
  rstr: 'rangedStrength',
  mdmg: 'magicDamage',
  prayer: 'prayer',
  slot: 'slot',
  speed: 'speed',
  attackrange: 'attackRange',
  combatstyle: 'combatStyle',
};

export function parseEquipmentStats(pageText: string): EquipmentStats | null {
  const parsed = parseWikitext(pageText);
  const bonusData = parsed.getInfobox('bonuses');
  if (!bonusData) return null;

  const stats: Partial<EquipmentStats> = {};
  for (const [wikiKey, ourKey] of Object.entries(WikiToEquipmentStatsKeys)) {
    const rawValue = bonusData[wikiKey];
    if (STRING_STAT_KEYS.has(ourKey)) {
      (stats as Record<string, unknown>)[ourKey] = rawValue ?? '';
    } else {
      (stats as Record<string, unknown>)[ourKey] = wikiNumber(rawValue);
    }
  }

  return stats as EquipmentStats;
}

export const WikiToItemKeys: Record<string, keyof Item> = {
  gemwname: 'geName',
  name: 'name',
  image: 'image',
  members: 'isMembers',
  tradeable: 'isTradeable',
  equipable: 'isEquipable',
  stackable: 'isStackable',
  exchange: 'isOnGrandExchange',
  quest: 'quest',
  edible: 'isEdible',
  bankable: 'isBankable',
  noteable: 'isNoteable',
  stacksinbank: 'stacksInBank',
  placeholder: 'isPlaceholder',
  wornoptions: 'wornOptions',
  options: 'options',
  destroy: 'drop',
  examine: 'examine',
  value: 'value',
  alchable: 'isAlchable',
  respawn: 'respawnTime',
  weight: 'weight',
  id: 'id',
};

export function parseItemFromWikiData(
  parsed: Record<string, string>,
  pageTitle: string,
  pageText: string,
  pageAliases: string[],
  geLimitsRecord: Record<string, number>
): Item[] {
  const hasMultiple = Object.keys(parsed).some((v) => v.endsWith('2'));

  let isInMainGame = true;

  // Skip removed items and jmod items
  if (
    'removal' in parsed ||
    pageTitle.includes('Redundant') ||
    pageTitle.startsWith('Sigil') ||
    pageText.includes('{{Deadman seasonal}}') ||
    pageText.includes('{{Beta}}') ||
    pageText.includes('{{Gone')
  ) {
    isInMainGame = false;
  }

  const equipmentStats = parseEquipmentStats(pageText);
  const preferredName = parsed.gemwname || parsed.name;

  const baseItem: Item = {
    id: wikiNumber(parsed.id),
    aliases: pageAliases || [],
    name: preferredName,
    geName: wikiString(parsed.gemwname),
    examine: parsed.examine,
    image: parsed.image,
    isEquipable: wikiBool(parsed.equipable),
    isAlchable: wikiBool(parsed.alchable),
    quest: wikiString(parsed.quest),
    isEdible: wikiBool(parsed.edible),
    isBankable: wikiBool(parsed.bankable, true),
    isNoteable: wikiBool(parsed.noteable),
    stacksInBank: wikiBool(parsed.stacksinbank, true),
    isPlaceholder: wikiBool(parsed.placeholder),
    wornOptions: parseListValue(parsed.wornoptions),
    isOnGrandExchange: wikiBool(parsed.exchange),
    isTradeable: wikiBool(parsed.tradeable),
    isMembers: wikiBool(parsed.members),
    isStackable: wikiBool(parsed.stackable),
    drop: parsed.destroy,
    options: parseListValue(parsed.options),
    respawnTime: wikiNumber(parsed.respawn),
    relatedItems: [],
    value: wikiNumber(parsed.value),
    weight: wikiNumber(parsed.weight, 0),
    limit: geLimitsRecord[preferredName] || 0,
    isInMainGame,
    ...(equipmentStats && { equipmentStats }),
  };

  const candidateItems: Item[] = [];

  if (hasMultiple) {
    let allVariants: Item[] = [];
    Object.keys(parsed).forEach((key: string) => {
      const candidateKey = key.match(/\d+$/);
      const endIndex = candidateKey ? Number(candidateKey[0]) : 0;
      const baseKey = key.replace(/\d+$/, '');
      if (key === baseKey || endIndex === 0) {
        return;
      }

      if (!allVariants[endIndex]) {
        allVariants[endIndex] = { ...baseItem };
      }

      let value;
      switch (baseKey) {
        case 'id':
        case 'value':
        case 'weight':
        case 'respawn':
          value = wikiNumber(parsed[key]);
          break;
        case 'name':
          value = parsed[`gemwname${endIndex}`] || parsed[key];
          break;
        case 'examine':
        case 'destroy':
        case 'image':
          value = parsed[key];
          break;
        case 'quest':
          value = wikiString(parsed[key]);
          break;
        case 'gemwname':
          value = wikiString(parsed[key]);
          allVariants[endIndex].name =
            parsed[key] || allVariants[endIndex].name;
          break;
        case 'options':
        case 'wornoptions':
          value = parseListValue(parsed[key]);
          break;
        case 'equipable':
        case 'alchable':
        case 'exchange':
        case 'tradeable':
        case 'stackable':
        case 'members':
        case 'edible':
        case 'noteable':
        case 'placeholder':
          value = wikiBool(parsed[key]);
          break;
        case 'bankable':
        case 'stacksinbank':
          value = wikiBool(parsed[key], true);
          break;
        default:
          break;
      }
      if (value !== undefined && value !== '') {
        allVariants[endIndex][WikiToItemKeys[baseKey] as keyof Item] =
          value as never;
      }
    });

    allVariants = allVariants.filter((v) => v.id);

    const itemIds = allVariants.map((v) => v.id);
    allVariants.forEach((v) => {
      v.relatedItems = itemIds.filter((id) => v.id !== id);
      v.limit = v.limit || geLimitsRecord[v.name] || 0;
    });

    candidateItems.push(...allVariants);
  } else if (baseItem.id) {
    candidateItems.push(baseItem);
  }

  return candidateItems;
}

export function extractImagesFromHtml(html: string): Map<number, string> {
  const images = new Map<number, string>();
  if (!html) return images;

  const dom = load(html);
  const infoboxRows = dom('.infobox-item tr, table.infobox tr');
  let pendingImage: string | null = null;

  infoboxRows.each((_, row) => {
    const el = dom(row);
    const th = el.find('th');
    const td = el.find('td');

    // Check for an image row — it appears BEFORE the ID row in the HTML
    const img = el.find('img').first();
    if (img.length) {
      const src = img.attr('src') || '';
      const match = src.match(/\/([^/]+?\.(?:png|jpg|gif))/i);
      if (match) {
        pendingImage = 'File:' + decodeURIComponent(match[1]);
      }
    }

    // When we hit an ID row, associate the pending image with this ID
    if (th.text().trim() === 'ID' && td.length && pendingImage) {
      const idText = td.text().trim();
      const firstId = Number(idText.split(',')[0].trim());
      if (!isNaN(firstId)) {
        images.set(firstId, pendingImage);
      }
      pendingImage = null;
    }
  });

  return images;
}

@Injectable()
export class ItemsExtractor {
  private logger: Logger = new Logger(ItemsExtractor.name);
  // Key = item name, value = GE limit
  private GELimitsRecord: Record<string, number> = {};

  private cachedItems: Item[] | null = null;
  private cachedGEItems: Item[] | null = null;

  constructor(
    private pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
    private readonly wikiRequestService: WikiRequestService
  ) {}

  public async extractAllItems() {
    this.logger.log('Starting to extract all items');
    const itemsPageList = await this.pageListDumper.getPagesFromTag('item');

    const GELimits = await this.wikiRequestService.getRawText(
      GELimitsModulePath,
      { action: 'raw' }
    );
    if (GELimits) {
      try {
        this.GELimitsRecord = JSON.parse(GELimits);
      } catch (e) {
        this.logger.warn(
          `Failed to parse GELimits module JSON; proceeding without GE limits`,
          e
        );
      }
    } else {
      this.logger.warn(
        `GELimits module fetch returned empty; proceeding without GE limits`
      );
    }

    const itemsFromPage = await Promise.all(
      itemsPageList.map((item) => this.extractItemFromPageId(item.id))
    );
    const items = itemsFromPage
      .filter((v) => v !== null)
      .reduce((acc: Item[], items) => {
        acc.push(...items!);
        return acc;
      }, [])
      .filter((v) => v);

    this.logger.log('Completed extracting all items');

    items.sort((a, b) => a?.name?.localeCompare(b.name) || 0);
    writeFileSync(ALL_ITEMS, JSON.stringify(items));
  }

  public getAllItems(): Item[] | null {
    if (!this.cachedItems) {
      const candidatePath = ALL_ITEMS;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, 'utf8');
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.warn('all items has invalid content', e);
      }
      this.cachedItems = parsed;
    }

    return this.cachedItems;
  }

  private itemIdMap: Map<number, Item> | null = null;
  public getItemById(itemId: number): Item | undefined {
    if (!this.itemIdMap) {
      this.fillItemIdMap();
    }

    return this.itemIdMap?.get(itemId);
  }

  private fillItemIdMap() {
    const m: Map<number, Item> = new Map();
    this.getAllItems()?.forEach((i) => m.set(i.id, i));
    this.itemIdMap = m;
    return m;
  }

  public getGEItems() {
    if (!this.cachedGEItems) {
      const allItems = this.getAllItems();
      if (!allItems) {
        return null;
      }
      this.cachedGEItems = allItems.filter(
        (i) => i.isOnGrandExchange && i.isInMainGame
      );
    }
    return this.cachedGEItems;
  }

  private itemNameMap: Map<string, Item> = new Map();

  public getItemByName(candidateName: string): Item | null {
    if (this.itemNameMap.size === 0) {
      this.itemNameMap = new Map();
      this.getAllItems()!.forEach((item) => {
        if (!this.itemNameMap.has(item.name)) {
          this.itemNameMap.set(item.name, item);
        } else {
          const otherItem = this.itemNameMap.get(item.name);
          // Score depending on the amount of "true", with priority to being in the main game
          const score =
            Number(item.isInMainGame) * 3 +
            Number(item.isOnGrandExchange) +
            Number(item.isTradeable);
          const otherScore =
            Number(otherItem?.isInMainGame) * 3 +
            Number(otherItem?.isOnGrandExchange) +
            Number(otherItem?.isTradeable);
          if (score > otherScore) {
            // Item most likely to be current and used takes the place
            this.itemNameMap.set(item.name, item);
          }
        }
      });
    }

    if (!this.itemNameMap.has(candidateName)) {
      return null;
    }
    return this.itemNameMap.get(candidateName) || null;
  }

  private async extractItemFromPageId(pageId: number): Promise<Item[] | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page) {
      return null;
    }

    const wikiParsed = parseWikitext(page.text!);
    const itemData = wikiParsed.getInfobox('item');
    if (!itemData) {
      console.warn(`Page not parsed: (${page.id}) ${page.title}`);
      return null;
    }

    const items = parseItemFromWikiData(
      itemData,
      page.title,
      page.text!,
      page.aliases || [],
      this.GELimitsRecord
    );

    if (items.length > 0 && !items[0].image && page.html) {
      const htmlImages = extractImagesFromHtml(page.html);
      if (htmlImages.size > 0) {
        for (const item of items) {
          if (!item.image && htmlImages.has(item.id)) {
            item.image = htmlImages.get(item.id);
          }
        }
      }
    }

    return items;
  }
}
