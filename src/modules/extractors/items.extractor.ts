import { Injectable, Logger } from '@nestjs/common';
import axios from 'axios';
import { existsSync, readFileSync, writeFileSync } from 'fs';
// @ts-ignore
import * as parseInfo from 'infobox-parser';
import { ALL_ITEMS } from '../../constants/paths';
import { Item } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';

const GELimitsModuleUrl =
  'https://oldschool.runescape.wiki/w/Module:GELimits/data.json?action=raw';

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

  private itemNameMap: Map<string, Item>;
  private aliasNameMap: Map<string, Item>;
  private fileNameMap: Map<string, Item>;

  private hasUnterminatedParenthesis(input: string): boolean {
    let depth = 0;
    for (const char of input) {
      if (char === '(') {
        depth += 1;
      } else if (char === ')') {
        depth -= 1;
        if (depth < 0) {
          return true;
        }
      }
      return depth !== 0;
    }
  }
  private weightScore(item: Item): number {
    return (
      Number(item.isInMainGame) * 3 +
      Number(item.isOnGrandExchange) +
      Number(item.isTradeable)
    );
  }
  public getItemByName(candidateName: string): Item | null {
    if (!this.itemNameMap) {
      this.itemNameMap = new Map();
      this.aliasNameMap = new Map();
      this.fileNameMap = new Map();
      this.getAllItems().forEach((item) => {
        if (!this.itemNameMap.has(item.name)) {
          this.itemNameMap.set(item.name, item);
        } else {
          const otherItem = this.itemNameMap.get(item.name);
          // Score depending on the amount of "true", with priority to being in the main game
          const score = this.weightScore(item);
          const otherScore = this.weightScore(otherItem);
          if (score > otherScore) {
            // Item most likely to be current and used takes the place
            this.itemNameMap.set(item.name, item);
          }
        }

        item.aliases.forEach((alias) => {
          if (!alias) return;
          // Not really sure why, but some aliases are missing the closing parenthesis
          const unterminated = this.hasUnterminatedParenthesis(alias);
          if (!this.aliasNameMap.has(alias)) {
            this.aliasNameMap.set(alias, item);
            if (unterminated) {
              this.aliasNameMap.set(alias + ')', item);
            }
          } else {
            const otherItem = this.aliasNameMap.get(alias);
            // Score depending on the amount of "true", with priority to being in the main game
            const score = this.weightScore(item);
            const otherScore = this.weightScore(otherItem);
            if (score > otherScore) {
              // Item most likely to be current and used takes the place
              this.aliasNameMap.set(alias, item);
              if (unterminated) {
                this.aliasNameMap.set(alias + ')', item);
              }
            }
          }
        });
        // Sometimes items alias list do not have the name with the parenthesis
        // But the filename usually does
        if (typeof item.image === 'string' && item.image.includes(')')) {
          const potentialName =
            item.image.replace('File:', '').replace('.png', '').split(')')[0] +
            ')';
          if (!this.fileNameMap.has(potentialName)) {
            this.fileNameMap.set(potentialName, item);
          }
        }
      });
    }
    if (!this.itemNameMap.has(candidateName)) {
      if (this.aliasNameMap.has(candidateName)) {
        return this.aliasNameMap.get(candidateName);
      } else if (this.fileNameMap.has(candidateName)) {
        return this.fileNameMap.get(candidateName);
      }
    }
    return this.itemNameMap.get(candidateName);
  }

  private extractItemFromPageId(pageId: number): Item[] | null {
    const page = this.pageContentDumper.getPageFromId(pageId);
    if (!page) {
      return null;
    }

    const candidateItems: Item[] = [];

    const parsed: WikiItem = parseInfo(
      page.rawContent.replace(/\{\|/g, '{a|').replace(/\{\{sic\}\}/g, '')
    ).general;
    if (Object.keys(parsed).length === 0) {
      console.warn(`Page not parsed: (${page.pageid}) ${page.title}`);
      return null;
    }

    // One page can have multiple variants of the item
    const hasMultiple = Object.keys(parsed).some((v) => v.endsWith('2'));

    let isInMainGame = true;

    // Skip removed items and jmod items
    if (
      'removal' in parsed ||
      page.title.includes('Redundant') ||
      page.pagename.startsWith('Sigil') ||
      page.rawContent.includes('{{Deadman seasonal}}') ||
      page.rawContent.includes('{{Beta}}') ||
      page.rawContent.includes('{{Gone')
    ) {
      isInMainGame = false;
    }

    const baseItem: Item = {
      id: Number(parsed.id),
      aliases: page.redirects || [],
      name: parsed.gemwname || parsed.name,
      examine: parsed.examine,
      image: parsed.image,
      isEquipable: parsed.equipable === 'Yes' || parsed.equipable === true,
      isAlchable: parsed.alchable === 'Yes' || parsed.alchable === true,
      isOnGrandExchange: parsed.exchange === 'Yes' || parsed.exchange === true,
      isTradeable: parsed.tradeable === 'Yes' || parsed.tradeable === true,
      isMembers: parsed.members === 'Yes' || parsed.members === true,
      isStackable: parsed.stackable === 'Yes' || parsed.stackable === true,
      drop: parsed.destroy,
      options: [],
      relatedItems: [],
      value: Number(parsed.value),
      weight: Number(parsed.weight),
      limit: this.GELimitsRecord[parsed.gemwname || parsed.name] || 0,
      isInMainGame,
    };

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
        switch (baseKey as keyof WikiItem) {
          case 'id':
          case 'value':
          case 'weight':
            value = Number((parsed as any)[key]);
            break;
          case 'name':
          case 'gemwname':
          case 'examine':
          case 'destroy':
            value = (parsed as any)[key];
            break;
          case 'equipable':
          case 'alchable':
          case 'exchange':
          case 'tradeable':
          case 'stackable':
          case 'members':
            value =
              (parsed as any)[key] === 'Yes' || (parsed as any)[key] === true;
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
