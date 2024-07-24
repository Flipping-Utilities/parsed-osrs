import { Injectable, Logger } from '@nestjs/common';
import axios from 'axios';
import { existsSync, readFileSync, writeFileSync } from 'fs';
// @ts-ignore
import * as parseInfo from 'infobox-parser';
import { ALL_ITEMS } from '../../constants/paths';
import { EquipmentStats, Item } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import * as wtf from 'wtf_wikipedia';

const GELimitsModuleUrl =
  'https://oldschool.runescape.wiki/w/Module:GELimits/data.json?action=raw';

interface WikiEquipmentStats {
  astab: string;
  aslash: string;
  acrush: string;
  amagic: string;
  arange: string;
  dstab: string;
  dslash: string;
  dcrush: string;
  dmagic: string;
  drange: string;
  str: string;
  rstr: string;
  mdmg: string;
  prayer: string;
  slot: string;
  speed: string;
  attackrange: string;
  combatstyle: string;
}

const WikiToEquipmentStatsKeys: Record<
  Partial<keyof WikiEquipmentStats>,
  keyof EquipmentStats
> = {
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
  str: 'str',
  rstr: 'rangedStr',
  mdmg: 'magicDamage',
  prayer: 'prayer',
  slot: 'slot',
  speed: 'speed',
  attackrange: 'attackRange',
  combatstyle: 'combatStyle',
};
interface WikiItem {
  gemwname?: string;
  name: string;
  // format: "File:1-3rds full jug.png"
  image: string;
  // format: ['2 November', '2004']
  // release: [string, string];
  // update: string;
  members: 'Yes' | 'No' | boolean;
  // quest: string;
  tradeable: 'Yes' | 'No' | boolean;
  // placeholder: "Yes" | "No" | boolean;
  equipable: 'Yes' | 'No' | boolean;
  stackable: 'Yes' | 'No' | boolean;
  // noteable: "Yes" | "No" | boolean;
  exchange: 'Yes' | 'No' | boolean;
  destroy: string;
  examine: string;
  value: string;
  alchable: 'Yes' | 'No' | boolean;
  weight: string;
  id: string;
}

const WikiToItemKeys: Record<Partial<keyof WikiItem>, keyof Item> = {
  gemwname: 'name',
  name: 'name',
  image: 'image',
  members: 'isMembers',
  tradeable: 'isTradeable',
  equipable: 'isEquipable',
  stackable: 'isStackable',
  exchange: 'isOnGrandExchange',
  destroy: 'drop',
  examine: 'examine',
  value: 'value',
  alchable: 'isAlchable',
  weight: 'weight',
  id: 'id',
};

@Injectable()
export class ItemsExtractor {
  private logger: Logger = new Logger(ItemsExtractor.name);
  // Key = item name, value = GE limit
  private GELimitsRecord: Record<string, number> = {};

  private cachedItems: Item[] | null = null;
  private cachedGEItems: Item[] | null = null;

  constructor(
    private pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllItems() {
    const itemsPageList = this.pageListDumper.getAllItems();

    const GELimits = (await axios.get(GELimitsModuleUrl)).data;
    this.GELimitsRecord = GELimits;

    const items = itemsPageList
      .map((item) => this.extractItemFromPageId(item.pageid))
      .filter((v) => v)
      .reduce((acc, items) => {
        acc.push(...items);
        return acc;
      }, [])
      .filter((v) => v);

    this.logger.debug(items.length);

    writeFileSync(ALL_ITEMS, JSON.stringify(items, null, 2));
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

  private itemIdMap: Map<number, Item>;
  public getItemById(itemId: number): Item | undefined {
    if (!this.itemIdMap) {
      this.fillItemIdMap();
    }

    return this.itemIdMap.get(itemId);
  }

  private fillItemIdMap() {
    const m: Map<number, Item> = new Map();
    this.getAllItems().forEach((i) => m.set(i.id, i));
    this.itemIdMap = m;
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

  private weightScoreMap(item: Item) {
    return (
      Number(item.isInMainGame) * 3 +
      Number(item.isOnGrandExchange) +
      Number(item.isTradeable)
    );
  }

  private itemNameMap: Map<string, Item>;
  public getItemByName(candidateName: string): Item | null {
    if (!this.itemNameMap) {
      this.itemNameMap = new Map();
      this.getAllItems().forEach((item) => {
        if (!this.itemNameMap.has(item.name)) {
          this.itemNameMap.set(item.name, item);
        } else {
          const otherItem = this.itemNameMap.get(item.name);
          // Score depending on the amount of "true", with priority to being in the main game
          const score = this.weightScoreMap(item);
          const otherScore = this.weightScoreMap(otherItem);
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
    return this.itemNameMap.get(candidateName);
  }

  private extractItemFromPageId(pageId: number): Item[] | null {
    const page = this.pageContentDumper.getPageFromId(pageId);
    if (!page) {
      return null;
    }

    const candidateItems: Item[] = [];
    const itemInfoBox: WikiItem = parseInfo(
      page.rawContent.replace(/\{\|/g, '{a|').replace(/\{\{sic\}\}/g, '')
    ).general;

    if (Object.keys(itemInfoBox).length === 0) {
      console.warn(`Page not parsed: (${page.pageid}) ${page.title}`);
      return null;
    }

    // One page can have multiple variants of the item
    const hasMultiple = Object.keys(itemInfoBox).some((v) => v.endsWith('2'));

    let isInMainGame = true;

    // Skip removed items and jmod items
    if (
      'removal' in itemInfoBox ||
      page.title.includes('Redundant') ||
      page.pagename.startsWith('Sigil') ||
      page.rawContent.includes('{{Deadman seasonal}}') ||
      page.rawContent.includes('{{Beta}}') ||
      page.rawContent.includes('{{Gone')
    ) {
      isInMainGame = false;
    }
    let equipmentStats: EquipmentStats = null;
    if (page.rawContent.includes('==Combat stats==')) {
      const cbSplit = page.rawContent.split('==Combat stats==')[1];
      const combatStats = cbSplit.slice(0, cbSplit.indexOf('}}'));

      const combatInfoBox: WikiEquipmentStats = parseInfo(combatStats).general;
      equipmentStats = {
        attackStab: Number(combatInfoBox.astab),
        attackSlash: Number(combatInfoBox.aslash),
        attackCrush: Number(combatInfoBox.acrush),
        attackMagic: Number(combatInfoBox.amagic),
        attackRanged: Number(combatInfoBox.arange),
        defendStab: Number(combatInfoBox.dstab),
        defendSlash: Number(combatInfoBox.dslash),
        defendCrush: Number(combatInfoBox.dcrush),
        defendMagic: Number(combatInfoBox.dmagic),
        defendRanged: Number(combatInfoBox.drange),
        str: Number(combatInfoBox.str),
        rangedStr: Number(combatInfoBox.rstr),
        magicDamage: Number(combatInfoBox.mdmg),
        prayer: Number(combatInfoBox.prayer),
        slot: combatInfoBox.slot,
        speed: Number(combatInfoBox.speed),
        attackRange: Number(combatInfoBox.attackrange),
        combatStyle: combatInfoBox.combatstyle,
      };
    }
    const baseItem: Item = {
      id: Number(itemInfoBox.id),
      aliases: page.redirects || [],
      name: itemInfoBox.gemwname || itemInfoBox.name,
      examine: itemInfoBox.examine,
      image: itemInfoBox.image,
      isEquipable:
        itemInfoBox.equipable === 'Yes' || itemInfoBox.equipable === true,
      isAlchable:
        itemInfoBox.alchable === 'Yes' || itemInfoBox.alchable === true,
      isOnGrandExchange:
        itemInfoBox.exchange === 'Yes' || itemInfoBox.exchange === true,
      isTradeable:
        itemInfoBox.tradeable === 'Yes' || itemInfoBox.tradeable === true,
      isMembers: itemInfoBox.members === 'Yes' || itemInfoBox.members === true,
      isStackable:
        itemInfoBox.stackable === 'Yes' || itemInfoBox.stackable === true,
      drop: itemInfoBox.destroy,
      options: [],
      relatedItems: [],
      value: Number(itemInfoBox.value),
      weight: Number(itemInfoBox.weight),
      limit: this.GELimitsRecord[itemInfoBox.gemwname || itemInfoBox.name] || 0,
      equipmentStats,
      isInMainGame,
    };

    if (hasMultiple) {
      let allVariants: Item[] = [];
      Object.keys(itemInfoBox).forEach((key: string) => {
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
        switch (baseKey as keyof WikiItem) {
          case 'id':
          case 'value':
          case 'weight':
            value = Number((itemInfoBox as any)[key]);
            break;
          case 'name':
          case 'gemwname':
          case 'examine':
          case 'destroy':
            value = (itemInfoBox as any)[key];
            break;
          case 'equipable':
          case 'alchable':
          case 'exchange':
          case 'tradeable':
          case 'stackable':
          case 'members':
            value =
              (itemInfoBox as any)[key] === 'Yes' ||
              (itemInfoBox as any)[key] === true;
            break;
          default:
            break;
        }
        if (value) {
          // @ts-ignore
          allVariants[endIndex][WikiToItemKeys[baseKey]] = value;
        }
      });

      allVariants = allVariants.filter((v) => v.id);

      const itemIds = allVariants.map((v) => v.id);
      allVariants.forEach((v) => {
        v.relatedItems = itemIds.filter((id) => v.id !== id);
        v.limit = v.limit || this.GELimitsRecord[v.name] || 0;
      });

      candidateItems.push(...allVariants);
    } else if (baseItem.id) {
      candidateItems.push(baseItem);
    }

    return candidateItems;
  }
}
