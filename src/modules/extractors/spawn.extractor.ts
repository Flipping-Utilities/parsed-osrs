import { PageTags } from "../../constants/tags";
import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_SPAWNS } from "../../constants/paths";
import { ItemSpawn } from "../../types";
import { PageContentDumper, PageListDumper } from "../dumpers";
import { wikiBool, wikiNumber } from "../../utils/wiki-coercion";
import { parseWikitext } from "../../utils/wikitext-parser";

@Injectable()
export class SpawnExtractor {
  private logger: Logger = new Logger(SpawnExtractor.name);
  private cachedSpawns: ItemSpawn[] | null = null;
  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
  ) {}

  public async extractAllItemSpawns() {
    this.logger.log("Start: extracting spawns");
    const itemsPageList = await this.pageListDumper.getPagesFromTag(PageTags.ITEM_SPAWN);

    const spawns: ItemSpawn[] = [];
    for await (const page of itemsPageList) {
      const spawnsFromPage = await this.extractSpawnsFromPageId(page.id);
      if (spawnsFromPage) {
        spawns.push(...spawnsFromPage.filter((v) => v));
      }
    }
    spawns.sort((a, b) => a.id - b.id);
    this.logger.log("End: extracting spawns");

    writeFileSync(ALL_SPAWNS, JSON.stringify(spawns));
  }

  public getAllSpawns(): ItemSpawn[] | null {
    if (!this.cachedSpawns) {
      const candidatePath = ALL_SPAWNS;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, "utf8");
      let parsed: ItemSpawn[] | null = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.warn("all spawns has invalid content", e);
      }
      this.cachedSpawns = parsed;
    }

    return this.cachedSpawns;
  }

  private async extractSpawnsFromPageId(pageId: number): Promise<ItemSpawn[] | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page) {
      return null;
    }
    const meta = parseWikitext(page.text!);

    const itemInfobox = meta.getInfobox("item");
    if (!itemInfobox) {
      this.logger.warn("No item infobox for page: " + pageId);
      return null;
    }

    const itemIds: Record<string, number> = {};

    const getItemId = (name: string) => {
      const id = itemIds[name.toLowerCase()];
      if (!id) {
        this.logger.warn("Item spawn id not found: " + page.title, name, itemIds);
        return Object.values(itemIds)[0];
      }
      return id;
    };

    if (itemInfobox.id) {
      itemIds[(itemInfobox.name ?? "").toLowerCase()] = wikiNumber(itemInfobox.id);
    } else {
      // Item variations
      Object.keys(itemInfobox)
        .filter((key) => key.startsWith("id"))
        .forEach((idKey) => {
          const postfix = idKey.substring("id".length);
          let nameKey = "name" + postfix;
          if (!itemInfobox[nameKey]) {
            nameKey = "name";
          }
          itemIds[(itemInfobox[nameKey] ?? "").toLowerCase()] = wikiNumber(itemInfobox[idKey]);
        });
    }

    const itemSpawnLines = meta.getTemplates("itemspawnline");

    return itemSpawnLines.flatMap((itemSpawnLine): ItemSpawn[] => {
      const data = itemSpawnLine as Record<string, unknown>;
      const plane = wikiNumber(data.plane);
      const spawnList = data.list;
      if (!Array.isArray(spawnList)) return [];
      return spawnList.map((spawnLine: string): ItemSpawn => {
        const name: string = String(data.name ?? "");
        const id = getItemId(name);
        const split = spawnLine.split(",");
        const quantity = split.length === 3 ? wikiNumber(split[2].slice(4), 1) : 1;
        return {
          id,
          name,
          quantity: quantity,
          x: wikiNumber(split[0]),
          y: wikiNumber(split[1]),
          plane,
          location: String(data.location ?? ""),
          members: wikiBool(data.members),
        };
      });
    });
  }
}
