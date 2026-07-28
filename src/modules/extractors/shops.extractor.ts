import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_SHOPS } from "../../constants/paths";
import { Shop, ShopItem } from "../../types";
import { PageContentDumper, PageListDumper } from "../dumpers";
import { ItemsExtractor } from "./items.extractor";
import { PageTags } from "../../constants/tags";
import { parseWikitext } from "../../utils/wikitext-parser";
import { wikiBool, wikiNumber, wikiString } from "../../utils/wiki-coercion";

function parseStoreItemGemw(val: unknown): boolean | undefined {
  if (val === null || val === undefined || val === "") return undefined;
  const lower = String(val).toLowerCase();
  if (lower === "no") return false;
  if (lower === "yes") return true;
  return undefined;
}

function parseStoreItemBuy(val: unknown): number | undefined {
  if (val === null || val === undefined || val === "") return undefined;
  const n = wikiNumber(val);
  // wikiNumber falls back to 0 for non-numerics like "N/A"; treat as absent
  if (n === 0 && !/^\s*\d/.test(String(val))) return undefined;
  return n;
}

export function parseShopFromContent(
  pageText: string,
  pageTitle: string,
  pageId: number,
  itemLookup: (name: string) => { id: number } | null,
): Shop | null {
  const parsed = parseWikitext(pageText);

  const headTemplates = parsed.getTemplates("storetablehead");
  if (!headTemplates.length) return null;

  const headData = headTemplates[0];

  const buyPercent = wikiNumber(headData.buymultiplier) / 1000;
  const sellPercent = wikiNumber(headData.sellmultiplier) / 1000;
  const buyChangePercent = wikiNumber(headData.delta) / 1000;

  const lineTemplates = parsed.getTemplates("storeline");

  const inventory: ShopItem[] = lineTemplates
    .map((lineData): ShopItem | undefined => {
      const name = String(lineData.name ?? "");
      const item = itemLookup(name)?.id;
      if (!item) return undefined;

      const shopItem: ShopItem = {
        baseQuantity: wikiNumber(lineData.stock),
        itemId: item,
        restockTime: wikiNumber(lineData.restock),
      };

      const buy = parseStoreItemBuy(lineData.buy);
      if (buy !== undefined) shopItem.buyPrice = buy;

      const cost = wikiNumber(lineData.cost);
      if (cost) shopItem.cost = cost;

      const gemw = parseStoreItemGemw(lineData.gemw);
      if (gemw !== undefined) shopItem.isOnGrandExchange = gemw;

      return shopItem;
    })
    .filter((v): v is ShopItem => v !== undefined);

  // Enrich with {{Infobox Shop}} metadata (location, owner, members, etc.)
  const shopInfobox = parsed.getInfobox("shop");

  const currencyFromHead = wikiString(headData.currency);

  const shop: Shop = {
    name: pageTitle,
    pageId,
    buyPercent,
    sellPercent,
    buyChangePercent,
    location: shopInfobox ? wikiString(shopInfobox.location) : "",
    owner: shopInfobox ? wikiString(shopInfobox.owner) : "",
    isMembers: shopInfobox ? wikiBool(shopInfobox.members) : null,
    currency: currencyFromHead || (shopInfobox ? wikiString(shopInfobox.currency) : ""),
    specialty: shopInfobox ? wikiString(shopInfobox.special) : "",
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
    private readonly pageContentDumper: PageContentDumper,
  ) {}

  public async extractAllShops() {
    this.logger.log("Starting to extract shops");

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

    this.logger.log("Finished extracting shops");

    return shops;
  }

  public getAllShops(): Shop[] | null {
    if (!this.cachedShops) {
      const candidatePath = ALL_SHOPS;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, "utf8");
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.debug("all sets has invalid content", e);
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
      this.itemExtractor.getItemByName(name),
    );
  }
}
