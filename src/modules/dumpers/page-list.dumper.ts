import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import {
  ALL_ITEM_PAGE_LIST,
  ALL_ITEM_SPAWNS_PAGE_LIST,
  ALL_MONSTERS_PAGE_LIST,
  ALL_SETS_PAGE_LIST,
  ALL_SHOPS_PAGE_LIST,
  GE_ITEM_PAGE_LIST,
  WIKI_PAGE_LIST,
} from '../../constants/paths';
import { eq, inArray } from 'drizzle-orm';
import { DatabaseService } from '../database/database.service';
import { PageTag, WikiPage } from '../database/schema';
import { WikiPageSlim, WikiRequestService } from '../wiki/wikiRequest.service';
import { PageTags } from '../../constants/tags';

@Injectable()
export class PageListDumper {
  private logger = new Logger(PageListDumper.name);
  private db: ReturnType<DatabaseService['getDb']>;

  constructor(
    private readonly wikiRequestService: WikiRequestService,
    private readonly databaseService: DatabaseService
  ) {
    this.db = this.databaseService.getDb();
  }

  /**
   * Dumps all of the wiki page name + ids
   */
  async fetchWikiPageList(): Promise<WikiPageSlim[]> {
    const properties = {
      action: 'query',
      list: 'allpages',
      aplimit: 'max',
      format: 'json',
      // Todo: Copy this but only get redirects, add them to the original pages
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

  async getWikiPageListDB(): Promise<Array<typeof WikiPage.$inferSelect>> {
    return this.db.select().from(WikiPage);
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
    const pagesToUpdate: typeof WikiPage[] = [];
    allPages.forEach((slimPage, i) => {
      if (i % 100 === 0) {
        console.log(`${i} / ${allPages.length}`);
      }
      try {
        // const page: typeof WikiPage = this.db.query.WikiPage.findFirst({
        //   where: (page, { eq }) => eq(page.id, slimPage.pageid),
        // });
        // Todo: Get all redirects in some other way
        // JSON.parse(
        //   readFileSync(`${WIKI_PAGES_FOLDER}/${slimPage.pageid}.json`, {
        //     encoding: 'utf8',
        //   })
        // );
        // const redirects = page?.redirects || [];
        // slimPage.redirects = redirects;
      } catch (e) {
        console.error(slimPage, e);
      }
    });
    // // this.db.insert(WikiPage).values(allPages);
    // await this.saveFile(WIKI_PAGE_LIST, allPages);

    this.logger.log('Dumping all redirect list - Completed');
  }

  /**
   * Fetches the list of all items
   * From the wiki itself, and returns a list of slim pages.
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

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.ITEM
    );
    // await this.saveFile(ALL_ITEM_PAGE_LIST, pages);
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

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.GE_ITEM
    );
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

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.SET
    );
    // await this.saveFile(ALL_SETS_PAGE_LIST, pages);
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

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.SHOP
    );
    // await this.saveFile(ALL_SHOPS_PAGE_LIST, pages);
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

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.MONSTER
    );
    // await this.saveFile(ALL_MONSTERS_PAGE_LIST, pages);
  }

  getMonsters(): WikiPageSlim[] {
    return this.getPageList(ALL_MONSTERS_PAGE_LIST);
  }

  async fetchTemplatePageList(template: string): Promise<WikiPageSlim[]> {
    const properties = {
      action: 'query',
      list: 'embeddedin',
      eititle: `Template:${template}`,
      eilimit: 'max',
      format: 'json',
    };

    const pages =
      await this.wikiRequestService.queryAllPagesPromise<WikiPageSlim>(
        'eicontinue',
        'embeddedin',
        properties
      );

    // Wiki responses have 'ns' property, remove it
    return pages
      .map((p) => ({
        pageid: p.pageid,
        title: p.title,
        redirects: [],
      }))
      .filter((page) => !page.title.includes(':'));
  }

  fetchItemSpawnPageList(): Promise<WikiPageSlim[]> {
    return this.fetchTemplatePageList('ItemSpawnLine');
  }

  async dumpItemSpawnPageList() {
    this.logger.log('Dump item spawn page list');
    const pages = await this.fetchItemSpawnPageList();
    this.logger.log('Dump item spawn page list - Completed');

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.ITEM_SPAWN
    );
    // await this.saveFile(ALL_ITEM_SPAWNS_PAGE_LIST, pages);
  }

  getItemSpawns(): WikiPageSlim[] {
    return this.getPageList(ALL_ITEM_SPAWNS_PAGE_LIST);
  }

  async getPagesFromTag(
    tag: string
  ): Promise<Array<typeof WikiPage.$inferSelect>> {
    const tags = await this.db
      .select()
      .from(PageTag)
      .where(eq(PageTag.tag, tag));
    const pageIds = tags.map((tag) => tag.wikiPageId);
    const pages = await this.db
      .select()
      .from(WikiPage)
      .where(inArray(WikiPage.id, pageIds));
    return pages;
  }

  private saveFile(path: string, content: unknown) {
    writeFileSync(path, JSON.stringify(content, null, 2));
  }
  private async addTag(pagesId: number[], tag: string) {
    try {
      await this.db.batch(
        // @ts-ignore
        pagesId.map((pageId) =>
          this.db
            .insert(PageTag)
            .values({ wikiPageId: pageId, tag })
            .onConflictDoNothing()
        )
      );
    } catch (e) {
      // This can happen if the page doesn't exist
      // Not optimal as it'll fail the batch, should fix
      console.error(e);
    }
  }

  private getPageList(path: string): WikiPageSlim[] {
    if (!existsSync(path)) {
      return [];
    }
    return JSON.parse(readFileSync(path, 'utf-8'));
  }
}
