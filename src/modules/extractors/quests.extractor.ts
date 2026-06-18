import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_QUESTS } from '../../constants/paths';
import { MapPoint, Quest } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { PageTags } from '../../constants/tags';
import { parseWikitext } from '../../utils/wikitext-parser';
import { wikiBool, wikiNumber, wikiString } from '../../utils/wiki-coercion';

function parseStartCoords(val: unknown): MapPoint | undefined {
  const m = String(val ?? '').match(/(\d+)[,:](\d+)/);
  return m ? { x: Number(m[1]), y: Number(m[2]) } : undefined;
}

function parseBulletList(val: unknown): string[] {
  if (!val) return [];
  return String(val)
    .split('\n')
    .map((line) => wikiString(line.replace(/^\s*\*+\s*/, '')))
    .filter(Boolean);
}

export function parseQuestFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[]
): Quest | null {
  const parsed = parseWikitext(pageText);
  const infobox = parsed.getInfobox('quest');
  if (!infobox) return null;

  const details = parsed.getTemplates('quest details')[0] ?? {};
  const rewards = parsed.getTemplates('quest rewards')[0] ?? {};

  const startCoords = parseStartCoords(details.startmap);

  const quest: Quest = {
    name: wikiString(infobox.name) || pageTitle,
    aliases: pageAliases,
    number: wikiNumber(infobox.number),
    members: wikiBool(infobox.members),
    series: wikiString(infobox.series),
    difficulty: wikiString(details.difficulty),
    length: wikiString(details.length),
    start: wikiString(details.start),
    description: wikiString(details.description),
    itemRequirements: parseBulletList(details.items),
    questPoints: wikiNumber(rewards.qp),
    rewards: parseBulletList(rewards.rewards),
  };

  if (startCoords) quest.startCoords = startCoords;

  return quest;
}

@Injectable()
export class QuestsExtractor {
  private logger = new Logger(QuestsExtractor.name);
  private cachedQuests: Quest[] | null = null;

  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllQuests(): Promise<Quest[]> {
    this.logger.log('Start: Extracting quests');

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.QUEST);
    const length = pages.length;
    const quests: Quest[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 50 === 0) {
        this.logger.debug(`Quests: ${i}/${length}`);
      }
      const quest = await this.extractQuestFromPageId(page.id);
      if (quest) quests.push(quest);
    }

    quests.sort((a, b) => a.number - b.number);
    if (quests.length) {
      writeFileSync(ALL_QUESTS, JSON.stringify(quests, null, 2));
    }

    this.logger.log('Done: Extracting quests');
    return quests;
  }

  public getAllQuests(): Quest[] | null {
    if (!this.cachedQuests) {
      if (!existsSync(ALL_QUESTS)) {
        return null;
      }
      try {
        this.cachedQuests = JSON.parse(readFileSync(ALL_QUESTS, 'utf8'));
      } catch (e) {
        this.logger.warn('all quests has invalid content', e);
      }
    }
    return this.cachedQuests;
  }

  private async extractQuestFromPageId(pageId: number): Promise<Quest | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    return parseQuestFromContent(page.text, page.title, page.aliases || []);
  }
}
