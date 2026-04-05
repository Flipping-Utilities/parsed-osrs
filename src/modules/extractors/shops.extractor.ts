import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_SHOPS } from '../../constants/paths';
import { Shop, ShopItem } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { ItemsExtractor } from './items.extractor';
import { PageTags } from '@/constants/tags';

export function parseShopFromContent(
  pageText: string,
  pageTitle: string,
  pageId: number,
  itemLookup: (name: string) => { id: number } | null
): Shop | null {
  const hasShop = pageText.includes('{{StoreTableHead');
  if (!hasShop) {
    return null;
  }

  const shopHeadRegex = /\{\{StoreTableHead\|(.+)\}\}/g;
  const shopHead = pageText.match(shopHeadRegex);
  if (shopHead?.length === 0 || !shopHead) {
    return null;
  }

  const shopMeta: [string, string | number][] = shopHead[0]
    .replace('{{StoreTableHead|', '')
    .replace('}}', '')
    .split('|')
    .map((v) => {
      let [key, value]: [string, string | number] = v.split('=') as [
        string,
        string
      ];
      if (!value) {
        return;
      }
      if (!isNaN(Number(value))) {
        value = Number(value);
      }
      return [key, value];
    })
    .filter((v) => Boolean(v)) as [string, string | number][];

  const buyPercent =
    (shopMeta.find(
      (v) => v[0].toLowerCase() === 'buymultiplier'
    )?.[1] as number) / 1000 || 0;
  const sellPercent =
    (shopMeta.find(
      (v) => v[0].toLowerCase() === 'sellmultiplier'
    )?.[1] as number) / 1000 || 0;
  const buyChangePercent =
    (shopMeta.find((v) => v[0].toLowerCase() === 'delta')?.[1] as number) /
      1000 || 0;

  const shopLineRegex = /\{\{StoreLine\|(.+)\}\}$/gm;

  const inventory = (
    pageText.match(shopLineRegex)?.map((v) =>
      v
        .replace('{{StoreLine|', '')
        .replace(/\}\}$/, '')
        .split('|')
        .map((v) => {
          let [key, value]: [string, string | number] = v.split('=') as [
            string,
            string
          ];
          if (!value) {
            return;
          }
          if (!isNaN(Number(value))) {
            value = Number(value);
          }
          return [key, value];
        })
        .filter((v) => v)
    ) as [string, string | number][][]
  )
    ?.map((v) => {
      const name = v.find((v) => v[0] === 'name') || '';
      const item = itemLookup(name[1]?.toString())?.id;
      if (!item) {
        return;
      }
      const stock = v.find((v) => v[0] === 'stock') || ['stock', 0];
      const restock = v.find((v) => v[0] === 'restock') || ['restock', 0];
      const shopItem: ShopItem = {
        baseQuantity: stock[1] as number,
        itemId: item,
        restockTime: restock[1] as number,
      };
      return shopItem;
    })
    .filter((v) => v);

  const shop: Shop = {
    name: pageTitle,
    pageId,
    buyPercent,
    sellPercent,
    buyChangePercent,
    inventory: inventory as ShopItem[],
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
