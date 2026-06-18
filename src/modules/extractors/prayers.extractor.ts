import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_PRAYERS } from '../../constants/paths';
import { Prayer } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { PageTags } from '../../constants/tags';
import { parseWikitext } from '../../utils/wikitext-parser';
import { wikiBool, wikiNumber, wikiString } from '../../utils/wiki-coercion';

export function parsePrayerFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[]
): Prayer | null {
  const parsed = parseWikitext(pageText);
  const data = parsed.getInfobox('prayer');
  if (!data) return null;

  const prayer: Prayer = {
    name: wikiString(data.name) || pageTitle,
    aliases: pageAliases,
    level: wikiNumber(data.level),
    drain: wikiNumber(data.drain),
    members: wikiBool(data.members),
    effect: wikiString(data.effect),
  };

  if (data.image) {
    prayer.image = data.image;
  }

  return prayer;
}

@Injectable()
export class PrayersExtractor {
  private logger = new Logger(PrayersExtractor.name);
  private cachedPrayers: Prayer[] | null = null;

  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllPrayers(): Promise<Prayer[]> {
    this.logger.log('Start: Extracting prayers');

    const prayerPages = await this.pageListDumper.getPagesFromTag(
      PageTags.PRAYER
    );
    const length = prayerPages.length;
    const prayers: Prayer[] = [];
    let i = 0;
    for await (const page of prayerPages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Prayers: ${i}/${length}`);
      }
      const prayer = await this.extractPrayerFromPageId(page.id);
      if (prayer) {
        prayers.push(prayer);
      }
    }

    prayers.sort((a, b) => a.name.localeCompare(b.name));
    if (prayers.length) {
      writeFileSync(ALL_PRAYERS, JSON.stringify(prayers, null, 2));
    }

    this.logger.log('Done: Extracting prayers');
    return prayers;
  }

  public getAllPrayers(): Prayer[] | null {
    if (!this.cachedPrayers) {
      if (!existsSync(ALL_PRAYERS)) {
        return null;
      }
      try {
        this.cachedPrayers = JSON.parse(readFileSync(ALL_PRAYERS, 'utf8'));
      } catch (e) {
        this.logger.warn('all prayers has invalid content', e);
      }
    }
    return this.cachedPrayers;
  }

  private async extractPrayerFromPageId(
    pageId: number
  ): Promise<Prayer | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    return parsePrayerFromContent(page.text, page.title, page.aliases || []);
  }
}
