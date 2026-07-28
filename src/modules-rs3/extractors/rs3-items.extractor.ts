import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_ITEMS } from "../../constants/rs3-paths";
import { Item } from "../../types";
import {
  extractImagesFromHtml,
  parseItemFromWikiData,
} from "../../modules/extractors/items.extractor";
import { parseWikitext } from "../../utils/wikitext-parser";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/**
 * RS3 counterpart of {@link ItemsExtractor}.
 *
 * Reuses the OSRS pure parsing functions (`parseItemFromWikiData`,
 * `extractImagesFromHtml`) since the `{{Infobox Item}}` shape is broadly
 * compatible. The orchestration (DB read, JSON write) is RS3-specific: pages
 * come from the RS3 DB and the result lands in `data/rs3/items/all-items.json`.
 *
 * RS3-specific notes:
 * - No `Module:GELimits/data.json` counterpart on the RS3 wiki — every item
 *   gets `limit = 0`. If/when an RS3 GE-limits source is identified, fetch
 *   it here and populate the record before calling `parseItemFromWikiData`.
 */
@Injectable()
export class Rs3ItemsExtractor {
  private logger: Logger = new Logger(Rs3ItemsExtractor.name);
  private cachedItems: Item[] | null = null;
  private cachedGEItems: Item[] | null = null;
  private itemIdMap: Map<number, Item> | null = null;
  private itemNameMap: Map<string, Item> = new Map();

  constructor(
    private pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllItems() {
    this.logger.log("Starting to extract all items (RS3)");
    const itemsPageList = await this.pageListDumper.getPagesFromTag("item");

    // RS3 has no Module:GELimits equivalent — pass an empty record.
    const GELimitsRecord: Record<string, number> = {};

    const itemsFromPage = await Promise.all(
      itemsPageList.map((item) => this.extractItemFromPageId(item.id, GELimitsRecord)),
    );
    const items = itemsFromPage
      .filter((v) => v !== null)
      .reduce((acc: Item[], items) => {
        acc.push(...items!);
        return acc;
      }, [])
      .filter((v) => v);

    this.logger.log("Completed extracting all items (RS3)");

    items.sort((a, b) => a?.name?.localeCompare(b.name) || 0);
    writeFileSync(ALL_ITEMS, JSON.stringify(items));
  }

  public getAllItems(): Item[] | null {
    if (!this.cachedItems) {
      const candidatePath = ALL_ITEMS;
      if (!existsSync(candidatePath)) {
        return null;
      }
      const pageContent = readFileSync(candidatePath, "utf8");
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.warn("all items has invalid content", e);
      }
      this.cachedItems = parsed;
    }
    return this.cachedItems;
  }

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
      this.cachedGEItems = allItems.filter((i) => i.isOnGrandExchange && i.isInMainGame);
    }
    return this.cachedGEItems;
  }

  public getItemByName(candidateName: string): Item | null {
    if (this.itemNameMap.size === 0) {
      this.itemNameMap = new Map();
      this.getAllItems()?.forEach((item) => {
        if (!this.itemNameMap.has(item.name)) {
          this.itemNameMap.set(item.name, item);
        } else {
          const otherItem = this.itemNameMap.get(item.name);
          const score =
            Number(item.isInMainGame) * 3 +
            Number(item.isOnGrandExchange) +
            Number(item.isTradeable);
          const otherScore =
            Number(otherItem?.isInMainGame) * 3 +
            Number(otherItem?.isOnGrandExchange) +
            Number(otherItem?.isTradeable);
          if (score > otherScore) {
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

  private async extractItemFromPageId(
    pageId: number,
    GELimitsRecord: Record<string, number>,
  ): Promise<Item[] | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page) {
      return null;
    }

    const wikiParsed = parseWikitext(page.text!);
    const itemData = wikiParsed.getInfobox("item");
    if (!itemData) {
      this.logger.warn(`Page not parsed: (${page.id}) ${page.title}`);
      return null;
    }

    const items = parseItemFromWikiData(
      itemData,
      page.title,
      page.text!,
      page.aliases || [],
      GELimitsRecord,
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
