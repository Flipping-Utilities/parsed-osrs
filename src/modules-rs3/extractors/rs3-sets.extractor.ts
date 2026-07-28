import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_SETS } from "../../constants/rs3-paths";
import { Set } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseSetFromContent } from "../../modules/extractors/sets.extractor";
import { Rs3ItemsExtractor } from "./rs3-items.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/**
 * RS3 counterpart of {@link SetsExtractor}. Reuses the OSRS
 * `parseSetFromContent` since the `{{CostLine}}` template shape is shared.
 */
@Injectable()
export class Rs3SetsExtractor {
  private logger: Logger = new Logger(Rs3SetsExtractor.name);
  private cachedSets: Set[] | null = null;

  constructor(
    private itemExtractor: Rs3ItemsExtractor,
    private pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllSets() {
    this.logger.log("Starting to extract sets (RS3)");
    const setPages = await this.pageListDumper.getPagesFromTag(PageTags.SET);
    const sets: Set[] = [];
    for await (const page of setPages) {
      const set = await this.extractSetFromPageId(page.id);
      if (set) {
        sets.push(set);
      }
    }
    sets.sort((a, b) => a.id - b.id);
    if (sets.length) {
      writeFileSync(ALL_SETS, JSON.stringify(sets));
    }
    this.logger.log("Done extracting sets (RS3)");
    return sets;
  }

  public getAllSets(): Set[] | null {
    if (!this.cachedSets) {
      const candidatePath = ALL_SETS;
      if (!existsSync(candidatePath)) {
        return null;
      }
      const pageContent = readFileSync(candidatePath, "utf8");
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.warn("all sets has invalid content", e);
      }
      this.cachedSets = parsed;
    }
    return this.cachedSets;
  }

  private async extractSetFromPageId(pageId: number): Promise<Set | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page) {
      return null;
    }

    const set = parseSetFromContent(page.text!, page.title, (name) =>
      this.itemExtractor.getItemByName(name),
    );

    if (!set) {
      this.logger.warn(`Page set has no components! Page "${page.title}" (${page.id})`);
      return null;
    }
    return set;
  }
}
