import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_SCENERY } from "../../constants/rs3-paths";
import { Scenery } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseSceneryFromContent } from "../../modules/extractors/scenery.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/** RS3 counterpart of {@link SceneryExtractor}. */
@Injectable()
export class Rs3SceneryExtractor {
  private logger = new Logger(Rs3SceneryExtractor.name);
  private cachedScenery: Scenery[] | null = null;

  constructor(
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllScenery(): Promise<Scenery[]> {
    this.logger.log("Start: Extracting scenery (RS3)");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.SCENERY);
    const length = pages.length;
    const scenery: Scenery[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Scenery: ${i}/${length}`);
      }
      scenery.push(...(await this.extractSceneryFromPageId(page.id)));
    }

    scenery.sort((a, b) => a.name.localeCompare(b.name));
    if (scenery.length) {
      writeFileSync(ALL_SCENERY, JSON.stringify(scenery, null, 2));
    }

    this.logger.log("Done: Extracting scenery (RS3)");
    return scenery;
  }

  public getAllScenery(): Scenery[] | null {
    if (!this.cachedScenery) {
      if (!existsSync(ALL_SCENERY)) {
        return null;
      }
      try {
        this.cachedScenery = JSON.parse(readFileSync(ALL_SCENERY, "utf8"));
      } catch (e) {
        this.logger.warn("all scenery has invalid content", e);
      }
    }
    return this.cachedScenery;
  }

  private async extractSceneryFromPageId(pageId: number): Promise<Scenery[]> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return [];
    }
    return parseSceneryFromContent(page.text, page.title, page.aliases || []);
  }
}
