import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_SHOPS } from "../../constants/rs3-paths";
import { Shop } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseShopFromContent } from "../../modules/extractors/shops.extractor";
import { Rs3ItemsExtractor } from "./rs3-items.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/**
 * RS3 counterpart of {@link ShopsExtractor}. Reuses the OSRS
 * `parseShopFromContent` since the `{{StoreLine}}` / `{{StoreTableHead}}`
 * template shape is shared between the two wikis.
 */
@Injectable()
export class Rs3ShopsExtractor {
  private logger: Logger = new Logger(Rs3ShopsExtractor.name);
  private cachedShops: Shop[] | null = null;

  constructor(
    private itemExtractor: Rs3ItemsExtractor,
    private pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllShops() {
    this.logger.log("Starting to extract shops (RS3)");

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

    this.logger.log("Finished extracting shops (RS3)");
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
        this.logger.debug("all shops has invalid content", e);
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
