import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_LOCATIONS } from "../../constants/rs3-paths";
import { GameLocation } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseLocationFromContent } from "../../modules/extractors/locations.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/** RS3 counterpart of {@link LocationsExtractor}. */
@Injectable()
export class Rs3LocationsExtractor {
  private logger = new Logger(Rs3LocationsExtractor.name);
  private cachedLocations: GameLocation[] | null = null;

  constructor(
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllLocations(): Promise<GameLocation[]> {
    this.logger.log("Start: Extracting locations (RS3)");

    const locationPages = await this.pageListDumper.getPagesFromTag(PageTags.LOCATION);
    const length = locationPages.length;
    const locations: GameLocation[] = [];
    let i = 0;
    for await (const page of locationPages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Locations: ${i}/${length}`);
      }
      const location = await this.extractLocationFromPageId(page.id);
      if (location) {
        locations.push(location);
      }
    }

    locations.sort((a, b) => a.name.localeCompare(b.name));
    if (locations.length) {
      writeFileSync(ALL_LOCATIONS, JSON.stringify(locations, null, 2));
    }

    this.logger.log("Done: Extracting locations (RS3)");
    return locations;
  }

  public getAllLocations(): GameLocation[] | null {
    if (!this.cachedLocations) {
      if (!existsSync(ALL_LOCATIONS)) {
        return null;
      }
      try {
        this.cachedLocations = JSON.parse(readFileSync(ALL_LOCATIONS, "utf8"));
      } catch (e) {
        this.logger.warn("all locations has invalid content", e);
      }
    }
    return this.cachedLocations;
  }

  private async extractLocationFromPageId(pageId: number): Promise<GameLocation | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    return parseLocationFromContent(page.text, page.title, page.aliases || []);
  }
}
