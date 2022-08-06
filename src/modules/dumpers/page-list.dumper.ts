import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import {
  ALL_ITEM_PAGE_LIST,
  ALL_MONSTERS_PAGE_LIST,
  ALL_SETS_PAGE_LIST,
  ALL_SHOPS_PAGE_LIST,
  GE_ITEM_PAGE_LIST,
  WIKI_PAGES_FOLDER,
  WIKI_PAGE_LIST,
} from '../../constants/paths';

import {
  WikiPageSlim,
  WikiPageWithContent,
  WikiRequestService,
} from '../wiki/wikiRequest.service';

@Injectable()
export class PageListDumper {
  private logger = new Logger(PageListDumper.name);

  constructor(private readonly wikiRequestService: WikiRequestService) {}

  /**
   * Dumps all of the wiki page name + ids
   */
  async fetchWikiPageList(): Promise<WikiPageSlim[]> {
    const properties = {
      action: 'query',
      list: 'allpages',
      aplimit: 'max',
      format: 'json',
      apfilterredir: 'nonredirects',
      apminsize: '5',
    };

    const pages =
      await this.wikiRequestService.queryAllPagesPromise<WikiPageSlim>(
        'apcontinue',
        'allpages',
        properties
      );
    // Wiki responses have 'ns' property, remove it
    return pages.map((p) => ({
      pageid: p.pageid,
      title: p.title,
      redirects: [],
    }));
  }

  /**
   * Writes the page list to the disk
   */
  async dumpWikiPageList(): Promise<void> {
    const pages = await this.fetchWikiPageList();
    await this.saveFile(WIKI_PAGE_LIST, pages);
  }

  getWikiPageList(): WikiPageSlim[] {
    return this.getPageList(WIKI_PAGE_LIST);
  }

  /**
   * Extract the Page redirects from the page content and augment the page list with them.
   * Must be run after at least 1 run of `dumpAllWikiPages`
   */
  async dumpRedirectList(): Promise<void> {
    this.logger.log('Dumping all redirect list');
    const allPages = this.getWikiPageList();
    allPages.forEach((slimPage, i) => {
      if (i % 100 === 0) {
        console.log(`${i} / ${allPages.length}`);
      }
      try {
        const page: WikiPageWithContent = JSON.parse(
          readFileSync(`${WIKI_PAGES_FOLDER}/${slimPage.pageid}.json`, {
            encoding: 'utf8',
          })
        );
        const redirects = page?.redirects || [];
        slimPage.redirects = redirects;
      } catch (e) {
        console.error(slimPage, e);
      }
    });
    await this.saveFile(WIKI_PAGE_LIST, allPages);

    this.logger.log('Dumping all redirect list - Completed');
  }

  /**
   * Fetches the list of all items
   */
  async fetchAllItemPageList(category = 'Items'): Promise<WikiPageSlim[]> {
    this.logger.log('Dump all item page list');

    const properties = {
      action: 'query',
      list: 'categorymembers',
      cmtitle: `Category:${category}`,
      cmlimit: 'max',
      format: 'json',
    };

    const pages =
      await this.wikiRequestService.queryAllPagesPromise<WikiPageSlim>(
        'cmcontinue',
        'categorymembers',
        properties
      );

    this.logger.log('Dump all item page list - Completed');

    // Wiki responses have 'ns' property, remove it
    return pages
      .map((p) => ({
        pageid: p.pageid,
        title: p.title,
        redirects: [],
      }))
      .filter((page) => !page.title.startsWith('Category:'));
  }

  /**
   * Fetches the list of all items that are listed on the GE
   */
  fetchGEItemPageList(): Promise<WikiPageSlim[]> {
    return this.fetchAllItemPageList('Grand Exchange items');
  }

  /**
   * Writes the all item list to the disk
   */
  async dumpAllItemPageList(): Promise<void> {
    const pages = await this.fetchAllItemPageList();
    await this.saveFile(ALL_ITEM_PAGE_LIST, pages);
  }

  getAllItems(): WikiPageSlim[] {
    return this.getPageList(ALL_ITEM_PAGE_LIST);
  }

  /**
   * Writes the GE page list to the disk
   */
  async dumpGEItemPageList(): Promise<void> {
    this.logger.log('Dump GE item page list');
    const pages = await this.fetchGEItemPageList();
    this.logger.log('Dump GE item page list - Done');

    await this.saveFile(GE_ITEM_PAGE_LIST, pages);
  }

  getGEItems(): WikiPageSlim[] {
    return this.getPageList(GE_ITEM_PAGE_LIST);
  }

  async fetchItemSetsPageList() {
    return this.fetchAllItemPageList('Item_sets');
  }
  async dumpItemSetsPageList() {
    this.logger.log('Dump item set page list');
    const pages = await this.fetchItemSetsPageList();
    this.logger.log('Dump item set page list - Completed');
    await this.saveFile(ALL_SETS_PAGE_LIST, pages);
  }

  getItemSets(): WikiPageSlim[] {
    return this.getPageList(ALL_SETS_PAGE_LIST);
  }

  async fetchShopPageList() {
    return this.fetchAllItemPageList('Shops');
  }
  async dumpShopPageList() {
    this.logger.log('Dump shop page list');
    const pages = await this.fetchShopPageList();
    this.logger.log('Dump shop page list - Completed');
    await this.saveFile(ALL_SHOPS_PAGE_LIST, pages);
  }

  getShops(): WikiPageSlim[] {
    return this.getPageList(ALL_SHOPS_PAGE_LIST);
  }

  async fetchMonstersPageList() {
    return this.fetchAllItemPageList('Monsters');
  }
  async dumpMonstersPageList() {
    this.logger.log('Dump monster page list');
    const pages = await this.fetchMonstersPageList();
    this.logger.log('Dump monster page list');
    await this.saveFile(ALL_MONSTERS_PAGE_LIST, pages);
  }

  getMonsters(): WikiPageSlim[] {
    return this.getPageList(ALL_MONSTERS_PAGE_LIST);
  }

  private saveFile(path: string, content: unknown) {
    writeFileSync(path, JSON.stringify(content, null, 2));
  }

  private getPageList(path: string): WikiPageSlim[] {
    if (!existsSync(path)) {
      return [];
    }
    return JSON.parse(readFileSync(path, 'utf-8'));
  }
}
