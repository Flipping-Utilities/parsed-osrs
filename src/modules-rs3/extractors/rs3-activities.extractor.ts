import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_ACTIVITIES } from "../../constants/rs3-paths";
import { Activity } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseActivityFromContent } from "../../modules/extractors/activities.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/** RS3 counterpart of {@link ActivitiesExtractor}. */
@Injectable()
export class Rs3ActivitiesExtractor {
  private logger = new Logger(Rs3ActivitiesExtractor.name);
  private cachedActivities: Activity[] | null = null;

  constructor(
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllActivities(): Promise<Activity[]> {
    this.logger.log("Start: Extracting activities (RS3)");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.ACTIVITY);
    const length = pages.length;
    const activities: Activity[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 50 === 0) {
        this.logger.debug(`Activities: ${i}/${length}`);
      }
      const activity = await this.extractActivityFromPageId(page.id);
      if (activity) activities.push(activity);
    }

    activities.sort((a, b) => a.name.localeCompare(b.name));
    if (activities.length) {
      writeFileSync(ALL_ACTIVITIES, JSON.stringify(activities, null, 2));
    }

    this.logger.log("Done: Extracting activities (RS3)");
    return activities;
  }

  public getAllActivities(): Activity[] | null {
    if (!this.cachedActivities) {
      if (!existsSync(ALL_ACTIVITIES)) {
        return null;
      }
      try {
        this.cachedActivities = JSON.parse(readFileSync(ALL_ACTIVITIES, "utf8"));
      } catch (e) {
        this.logger.warn("all activities has invalid content", e);
      }
    }
    return this.cachedActivities;
  }

  private async extractActivityFromPageId(pageId: number): Promise<Activity | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    return parseActivityFromContent(page.text, page.title, page.aliases || []);
  }
}
