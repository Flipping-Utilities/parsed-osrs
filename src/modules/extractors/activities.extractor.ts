import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_ACTIVITIES } from "../../constants/paths";
import { Activity } from "../../types";
import { PageContentDumper, PageListDumper } from "../dumpers";
import { PageTags } from "../../constants/tags";
import { parseWikitext } from "../../utils/wikitext-parser";
import { parseMapTemplate } from "../../utils/map-parser";
import { wikiBool, wikiString, parseListValue } from "../../utils/wiki-coercion";

export function parseActivityFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[],
): Activity | null {
  const parsed = parseWikitext(pageText);
  const data = parsed.getInfobox("activity");
  if (!data) return null;

  let position: { x: number; y: number } | undefined;
  for (const mapTemplate of parsed.getTemplates("map")) {
    const map = parseMapTemplate(mapTemplate);
    if (map?.point) {
      position = map.point;
      break;
    }
  }

  const activity: Activity = {
    name: wikiString(data.name) || pageTitle,
    aliases: pageAliases,
    type: wikiString(data.type),
    members: wikiBool(data.members),
    location: wikiString(data.location),
    players: wikiString(data.players),
    skills: parseListValue(data.skills)
      .map((s) => wikiString(s))
      .filter(Boolean),
  };

  const leagueRegion = wikiString(data.leagueregion);
  if (leagueRegion) activity.leagueRegion = leagueRegion;
  if (position) activity.position = position;

  return activity;
}

@Injectable()
export class ActivitiesExtractor {
  private logger = new Logger(ActivitiesExtractor.name);
  private cachedActivities: Activity[] | null = null;

  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
  ) {}

  public async extractAllActivities(): Promise<Activity[]> {
    this.logger.log("Start: Extracting activities");

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

    this.logger.log("Done: Extracting activities");
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
