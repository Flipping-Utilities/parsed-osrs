import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_LOCATIONS } from '../../constants/paths';
import { GameLocation, RelativeLocation } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { PageTags } from '../../constants/tags';
import { parseWikitext } from '../../utils/wikitext-parser';
import { parseMapTemplate } from '../../utils/map-parser';
import { wikiBool, wikiString } from '../../utils/wiki-coercion';

export function parseLocationFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[]
): GameLocation | null {
  const parsed = parseWikitext(pageText);
  const data = parsed.getInfobox('location');
  if (!data) return null;

  const location: GameLocation = {
    name: wikiString(data.name) || pageTitle,
    aliases: pageAliases,
    type: wikiString(data.type),
    members: wikiBool(data.members),
  };

  if (data.location) location.region = wikiString(data.location);
  if (data.capital) location.capital = wikiString(data.capital);
  if (data.leagueregion) location.leagueRegion = wikiString(data.leagueregion);

  const relativeTemplates = parsed.getTemplates('relativelocation');
  if (relativeTemplates.length) {
    const rl = relativeTemplates[0];
    const rel: RelativeLocation = {};
    const north = wikiString(rl.north);
    const south = wikiString(rl.south);
    const east = wikiString(rl.east);
    const west = wikiString(rl.west);
    if (north) rel.north = north;
    if (south) rel.south = south;
    if (east) rel.east = east;
    if (west) rel.west = west;
    if (Object.keys(rel).length) location.relativeLocation = rel;
  }

  for (const mapTemplate of parsed.getTemplates('map')) {
    const map = parseMapTemplate(mapTemplate);
    if (map?.polygon) {
      location.polygon = map.polygon;
      break;
    }
  }
  if (!location.polygon) {
    for (const mapTemplate of parsed.getTemplates('map')) {
      const map = parseMapTemplate(mapTemplate);
      if (map?.point) {
        location.position = map.point;
        break;
      }
    }
  }

  return location;
}

@Injectable()
export class LocationsExtractor {
  private logger = new Logger(LocationsExtractor.name);
  private cachedLocations: GameLocation[] | null = null;

  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllLocations(): Promise<GameLocation[]> {
    this.logger.log('Start: Extracting locations');

    const locationPages = await this.pageListDumper.getPagesFromTag(
      PageTags.LOCATION
    );
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

    this.logger.log('Done: Extracting locations');
    return locations;
  }

  public getAllLocations(): GameLocation[] | null {
    if (!this.cachedLocations) {
      if (!existsSync(ALL_LOCATIONS)) {
        return null;
      }
      try {
        this.cachedLocations = JSON.parse(readFileSync(ALL_LOCATIONS, 'utf8'));
      } catch (e) {
        this.logger.warn('all locations has invalid content', e);
      }
    }
    return this.cachedLocations;
  }

  private async extractLocationFromPageId(
    pageId: number
  ): Promise<GameLocation | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    return parseLocationFromContent(page.text, page.title, page.aliases || []);
  }
}
