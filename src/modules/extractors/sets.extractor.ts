import { Injectable, Logger } from '@nestjs/common';
import { load } from 'cheerio';
import { existsSync, readFileSync, writeFileSync } from 'fs';
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
      writeFileSync(ALL_SETS, JSON.stringify(sets, null, 2));
    }
    this.logger.log('DOne extracting sets');
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
    const title = load(page.title).text();

    /*
     * Set format:
     * {{CostTableHead}}
     * {{CostLine|Ancient page 1}}
     * {{CostLine|Ancient page 2}}
     * {{CostLine|Ancient page 3}}
     * {{CostLine|Ancient page 4}}
     * {{CostTableBottom|total=y|compare={{PAGENAME}}}};
     */

    const matcher = /\{\{CostLine\|(.+)\}\}/gm;
    const components = Array.from(page.text.matchAll(matcher));
    if (!components.length) {
      this.logger.warn('No components', title, page.id);
      return null;
    }
    // Blue mystic sets has |disambiguation, strip it
    const componentNames = components.map((c) => c[1].split('|')[0]);
    const componentIds = componentNames.map(
      (name) => this.itemExtractor.getItemByName(name)?.id
    );
    const set: Set = {
      id: this.itemExtractor.getItemByName(title)?.id,
      name: title,
      componentIds,
    };
    if (!set.id) {
      this.logger.warn(`No set id!`, title);
    }
    if (!componentIds.every((c) => c)) {
      this.logger.log(
        `Missing a component id: ${componentNames} ${componentIds}`
      );
    }
    return set;
  }
}
