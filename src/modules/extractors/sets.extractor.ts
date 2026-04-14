import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { parseWikitext } from '../../utils/wikitext-parser';
import { ALL_SETS } from '../../constants/paths';
import { PageTags } from '../../constants/tags';
import { Set } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { ItemsExtractor } from './items.extractor';

@Injectable()
export class SetsExtractor {
  private logger: Logger = new Logger(SetsExtractor.name);
  private cachedSets: Set[] | null = null;

  constructor(
    private itemExtractor: ItemsExtractor,
    private pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllSets() {
    this.logger.log('Starting to extract sets');
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
    this.logger.log('Done extracting sets');
    return sets;
  }

  public getAllSets(): Set[] | null {
    if (!this.cachedSets) {
      const candidatePath = ALL_SETS;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, 'utf8');
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.warn('all sets has invalid content', e);
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
      this.itemExtractor.getItemByName(name)
    );

    if (!set) {
      this.logger.warn(
        `Page set has no components! Page "${page.title}" (${page.id})`
      );
      return null;
    }
    if (!set.id) {
      this.logger.warn(`No set id!`, page.title);
    }
    if (set.componentIds.length !== set.componentIds.filter((c) => c).length) {
      this.logger.log(`Missing a component id: ${set.componentIds}`);
    }
    return set;
  }
}

export function parseSetFromContent(
  pageText: string,
  title: string,
  itemLookup: (name: string) => { id: number } | null
): Set | null {
  const parsed = parseWikitext(pageText);
  const costLines = parsed.getTemplates('costline');
  if (!costLines.length) {
    return null;
  }

  const componentNames = costLines.map((t) => String(t.item ?? ''));
  const componentIds: number[] = componentNames
    .map((name) => itemLookup(name)?.id)
    .filter((v): v is number => v !== undefined);

  const set: Set = {
    id: itemLookup(title)?.id ?? 0,
    name: title,
    componentIds,
  };
  return set;
}
