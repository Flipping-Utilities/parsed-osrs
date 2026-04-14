import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_SHOPS } from '../../constants/paths';
import { Shop, ShopItem } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { ItemsExtractor } from './items.extractor';
import { PageTags } from '../../constants/tags';
import { parseWikitext } from '../../utils/wikitext-parser';
import { wikiNumber } from '../../utils/wiki-coercion';

export function parseShopFromContent(
  pageText: string,
  pageTitle: string,
  pageId: number,
  itemLookup: (name: string) => { id: number } | null
): Shop | null {
  const parsed = parseWikitext(pageText);

  const headTemplates = parsed.getTemplates('storetablehead');
  if (!headTemplates.length) return null;

  const headData = headTemplates[0];

  const buyPercent = wikiNumber(headData.buymultiplier) / 1000;
  const sellPercent = wikiNumber(headData.sellmultiplier) / 1000;
  const buyChangePercent = wikiNumber(headData.delta) / 1000;

  const lineTemplates = parsed.getTemplates('storeline');

  const inventory: ShopItem[] = lineTemplates
    .map((lineData): ShopItem | undefined => {
      const name = String(lineData.name ?? '');
      const item = itemLookup(name)?.id;
      if (!item) return undefined;

      return {
        baseQuantity: wikiNumber(lineData.stock),
        itemId: item,
        restockTime: wikiNumber(lineData.restock),
      };
    })
    .filter((v): v is ShopItem => v !== undefined);

  const shop: Shop = {
    name: pageTitle,
    pageId,
    buyPercent,
    sellPercent,
    buyChangePercent,
    inventory,
  };

  return shop;
}

@Injectable()
export class ShopsExtractor {
  private logger: Logger = new Logger(ShopsExtractor.name);

  private cachedShops: Shop[] | null = null;

  constructor(
    private itemExtractor: ItemsExtractor,
    private pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllShops() {
    this.logger.log('Starting to extract shops');

    const shopPages = await this.pageListDumper.getPagesFromTag(PageTags.SHOP);
    const shops: Shop[] = [];
    for await (const page of shopPages) {
      const shop = await this.extractShopFromPageId(page.id);
      if (shop) {
        shops.push(shop);
      }
    }
    shops.sort((a, b) => a.name.localeCompare(b.name));

    if (shops.length) {
      writeFileSync(ALL_SHOPS, JSON.stringify(shops));
    }

    this.logger.log('Finished extracting shops');

    return shops;
  }

  public getAllShops(): Shop[] | null {
    if (!this.cachedShops) {
      const candidatePath = ALL_SHOPS;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, 'utf8');
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.debug('all sets has invalid content', e);
      }
      this.cachedShops = parsed;
    }

    return this.cachedShops;
  }

  private async extractShopFromPageId(pageId: number): Promise<Shop | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page) {
      return null;
    }

    return parseShopFromContent(page.text!, page.title, page.id, (name) =>
      this.itemExtractor.getItemByName(name)
    );
  }
}
