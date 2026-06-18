import { Injectable, Logger } from '@nestjs/common';
import { eq, inArray } from 'drizzle-orm';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import {
  ALL_ITEM_PAGE_LIST,
  ALL_ITEM_SPAWNS_PAGE_LIST,
  ALL_MONSTERS_PAGE_LIST,
  ALL_NEWS_PAGE_LIST,
  ALL_PRAYERS_PAGE_LIST,
  ALL_RECIPES_PAGE_LIST,
  ALL_SETS_PAGE_LIST,
  ALL_SHOPS_PAGE_LIST,
  ALL_SPELLS_PAGE_LIST,
  ALL_LOCATIONS_PAGE_LIST,
  ALL_NPCS_PAGE_LIST,
  ALL_SCENERY_PAGE_LIST,
  ALL_QUESTS_PAGE_LIST,
  ALL_ACTIVITIES_PAGE_LIST,
  ALL_MUSIC_PAGE_LIST,
  GE_ITEM_PAGE_LIST,
  WIKI_PAGE_LIST,
} from '../../constants/paths';
import { PageTags } from '../../constants/tags';
import { DatabaseService } from '../database/database.service';
import { PageTag, WikiPage } from '../database/schema';
import { WikiPageSlim, WikiRequestService } from '../wiki/wikiRequest.service';

type WikiRedirectResponse = {
  pageid: number;
  title: string;
  redirects?: Array<{ pageid: number; ns: number; title: string }>;
};

// Number of UPDATE statements per drizzle `db.batch()` call. SQLite has a
// hard limit on SQL variables per statement (999 by default, 32766 with
// SQLITE_MAX_VARIABLE_NUMBER); chunking well below that keeps transactions
// short and avoids holding a write lock for seconds at a time.
const REDIRECT_DB_BATCH_SIZE = 1000;

// MediaWiki caps `titles=A|B|...` at 50 per request for anonymous/bot users.
const REDIRECT_TITLES_PER_REQUEST = 50;

/**
 * Pure helper: given every DB page row and every redirect-list response from
 * the wiki, return the set of pages whose `aliases` actually need writing.
 *
 * This replaces the old inline loop, which was O(n·m) due to `allPages.find()`
 * inside a `forEach`. It also implements the **delta skip**: a page whose
 * computed alias set is identical to its existing aliases is omitted from the
 * return value, so the caller doesn't waste a DB UPDATE on it.
 *
 * Behaviour preserved from the original:
 * - Aliases only ever grow — entries that are missing from the current
 *   response are NOT pruned. This matches the historical "additive" contract.
 * - A response with no `redirects` property is a no-op for that page.
 * - Responses targeting pageids that aren't in `pages` are dropped silently
 *   (matches the old `if (!page) return;`).
 *
 * @returns Array of `{ id, aliases }` for every page whose aliases changed.
 *          Caller should issue a single `UPDATE ... SET aliases = ?` per entry.
 */
export function mergeRedirects(
  pages: Array<{ id: number; aliases?: string[] | null }>,
  responses: WikiRedirectResponse[]
): Array<{ id: number; aliases: string[] }> {
  // Local working copy keyed by page id so multiple responses for the same
  // pageid (pagination) accumulate correctly without mutating the input.
  const work = new Map<
    number,
    { aliases: string[]; aliasSet: Set<string>; changed: boolean }
  >();
  for (const page of pages) {
    const aliases = page.aliases ?? [];
    work.set(page.id, {
      aliases: [...aliases],
      aliasSet: new Set(aliases),
      changed: false,
    });
  }

  for (const resp of responses) {
    const entry = work.get(resp.pageid);
    if (!entry) continue;
    const incoming = resp.redirects?.map((r) => r.title) ?? [];
    for (const title of incoming) {
      if (!entry.aliasSet.has(title)) {
        entry.aliasSet.add(title);
        entry.aliases.push(title);
        entry.changed = true;
      }
    }
  }

  const result: Array<{ id: number; aliases: string[] }> = [];
  for (const [id, entry] of work) {
    if (entry.changed) {
      result.push({ id, aliases: entry.aliases });
    }
  }
  return result;
}

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
    // const [page] = pages;
    // await this.db
    //   .insert(WikiPage)
    //   .values({ id: page.pageid, title: page.title })
    //   .onConflictDoUpdate({ target: WikiPage.id, set: { title: page.title } });
    await this.saveFile(WIKI_PAGE_LIST, pages);
  }

  async getWikiPageListDB(): Promise<Array<typeof WikiPage.$inferSelect>> {
    return this.db.select().from(WikiPage);
  }

  getWikiPageList(): WikiPageSlim[] {
    return this.getPageList(WIKI_PAGE_LIST);
  }

  /**
   * Resolves and persists the redirect/alias list for every wiki page in the
   * DB. Must be run after at least one run of the page-content dumper, so
   * that `WikiPage` rows exist.
   *
   * Algorithm:
   * 1. Load all pages from DB (title + current aliases).
   * 2. Query the wiki in chunks of {@link REDIRECT_TITLES_PER_REQUEST} titles,
   *    using `prop=redirects&rdlimit=max`. Pagination (`rdcontinue`) is
   *    handled inside `WikiRequestService.queryAllPagesPromise`.
   * 3. Merge responses into pages via {@link mergeRedirects}, which is O(n)
   *    (Map-based) and returns only the rows whose aliases actually changed.
   * 4. Persist the changed rows in batches of {@link REDIRECT_DB_BATCH_SIZE}.
   *
   * Improvements over the original implementation:
   * - O(n·m) `allPages.find()` replaced with an O(n) Map lookup inside
   *   {@link mergeRedirects}.
   * - `db.batch(...)` is now `await`ed (the original dropped the promise on
   *   the floor, so the function resolved before the DB writes finished).
   * - The DB batch is chunked at 1000 UPDATEs/transaction to stay under
   *   SQLite's variable limit and to keep write-lock duration reasonable.
   * - Delta skip: rows whose aliases haven't changed are never sent to the DB.
   * - Dead `titles = 'Members|Minigames'` placeholder removed.
   */
  async dumpRedirectList(): Promise<void> {
    this.logger.log('Start: Dumping redirect list');
    const allPages = await this.getWikiPageListDB();

    const allTitles = allPages.map((p) => p.title);
    const totalTitleChunks = Math.ceil(
      allTitles.length / REDIRECT_TITLES_PER_REQUEST
    );

    const responses: WikiRedirectResponse[] = [];
    for (
      let i = 0, chunkIdx = 0;
      i < allTitles.length;
      i += REDIRECT_TITLES_PER_REQUEST, chunkIdx++
    ) {
      if (chunkIdx % 20 === 0) {
        this.logger.verbose(
          `Querying redirect chunk ${chunkIdx + 1} / ${totalTitleChunks}`
        );
      }
      const titles = allTitles
        .slice(i, i + REDIRECT_TITLES_PER_REQUEST)
        .join('|');
      const chunkResults =
        await this.wikiRequestService.queryAllPagesPromise<WikiRedirectResponse>(
          'rdcontinue',
          'pages',
          {
            action: 'query',
            format: 'json',
            prop: 'redirects',
            rdlimit: 'max',
            titles,
          }
        );
      responses.push(...chunkResults);
    }

    const toUpdate = mergeRedirects(allPages, responses);
    this.logger.verbose(
      `${toUpdate.length} / ${allPages.length} pages have new aliases to persist`
    );

    const totalDbChunks = Math.ceil(toUpdate.length / REDIRECT_DB_BATCH_SIZE);
    for (let i = 0; i < toUpdate.length; i += REDIRECT_DB_BATCH_SIZE) {
      const chunk = toUpdate.slice(i, i + REDIRECT_DB_BATCH_SIZE);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await this.db.batch(
        // @ts-expect-error - drizzle batch typing is overly strict across versions
        chunk.map(({ id, aliases }) =>
          this.db.update(WikiPage).set({ aliases }).where(eq(WikiPage.id, id))
        )
      );
      const chunkNo = Math.floor(i / REDIRECT_DB_BATCH_SIZE) + 1;
      this.logger.debug(
        `Persisted redirect chunk ${chunkNo} / ${totalDbChunks} (${chunk.length} rows)`
      );
    }

    this.logger.log('End: Dumping redirect list');
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
    console.log(pages.length, pages.slice(60));
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
  }

  getMonsters(): WikiPageSlim[] {
    return this.getPageList(ALL_MONSTERS_PAGE_LIST);
  }

  async fetchPrayersPageList() {
    return this.fetchAllItemPageList('Prayers');
  }

  async dumpPrayersPageList() {
    this.logger.log('Dump prayer page list');
    const pages = await this.fetchPrayersPageList();
    this.logger.log('Dump prayer page list - Completed');

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.PRAYER
    );
  }

  getPrayers(): WikiPageSlim[] {
    return this.getPageList(ALL_PRAYERS_PAGE_LIST);
  }

  async fetchSpellsPageList() {
    return this.fetchAllItemPageList('Spells');
  }

  async dumpSpellsPageList() {
    this.logger.log('Dump spell page list');
    const pages = await this.fetchSpellsPageList();
    this.logger.log('Dump spell page list - Completed');

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.SPELL
    );
  }

  getSpells(): WikiPageSlim[] {
    return this.getPageList(ALL_SPELLS_PAGE_LIST);
  }

  /**
   * Fetches all pages transcluding {{Infobox Location}} — regions, cities,
   * settlements, dungeons, and other named places.
   */
  fetchLocationPageList(): Promise<WikiPageSlim[]> {
    return this.fetchTemplatePageList('Infobox Location');
  }

  async dumpLocationPageList() {
    this.logger.log('Dump location page list');
    const pages = await this.fetchLocationPageList();
    this.logger.log('Dump location page list - Completed');

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.LOCATION
    );
    await this.saveFile(ALL_LOCATIONS_PAGE_LIST, pages);
  }

  getLocations(): WikiPageSlim[] {
    return this.getPageList(ALL_LOCATIONS_PAGE_LIST);
  }

  async fetchInfoboxPageList(template: string) {
    return this.fetchTemplatePageList(template);
  }

  async dumpNpcPageList() {
    this.logger.log('Dump NPC page list');
    const pages = await this.fetchInfoboxPageList('Infobox NPC');
    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.NPC
    );
    this.logger.log('Dump NPC page list - Completed');
  }

  getNpcs(): WikiPageSlim[] {
    return this.getPageList(ALL_NPCS_PAGE_LIST);
  }

  async dumpSceneryPageList() {
    this.logger.log('Dump scenery page list');
    const pages = await this.fetchInfoboxPageList('Infobox Scenery');
    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.SCENERY
    );
    this.logger.log('Dump scenery page list - Completed');
  }

  getScenery(): WikiPageSlim[] {
    return this.getPageList(ALL_SCENERY_PAGE_LIST);
  }

  async dumpQuestPageList() {
    this.logger.log('Dump quest page list');
    const pages = await this.fetchInfoboxPageList('Infobox Quest');
    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.QUEST
    );
    this.logger.log('Dump quest page list - Completed');
  }

  getQuests(): WikiPageSlim[] {
    return this.getPageList(ALL_QUESTS_PAGE_LIST);
  }

  async dumpActivityPageList() {
    this.logger.log('Dump activity page list');
    const pages = await this.fetchInfoboxPageList('Infobox Activity');
    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.ACTIVITY
    );
    this.logger.log('Dump activity page list - Completed');
  }

  getActivities(): WikiPageSlim[] {
    return this.getPageList(ALL_ACTIVITIES_PAGE_LIST);
  }

  async dumpMusicPageList() {
    this.logger.log('Dump music page list');
    const pages = await this.fetchInfoboxPageList('Infobox Music');
    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.MUSIC
    );
    await this.saveFile(ALL_MUSIC_PAGE_LIST, pages);
    this.logger.log('Dump music page list - Completed');
  }

  getMusic(): WikiPageSlim[] {
    return this.getPageList(ALL_MUSIC_PAGE_LIST);
  }

  /**
   * Fetches every page in the `Update:` namespace (ns=112). These are the
   * historical Jagex newsposts (game updates, patch notes, developer blogs,
   * behind the scenes, etc.). Uses `allpages` scoped to ns=112 because the
   * main wiki dump (`fetchWikiPageList`) only covers the main namespace.
   */
  fetchNewsPageList(): Promise<WikiPageSlim[]> {
    const properties = {
      action: 'query',
      list: 'allpages',
      apnamespace: '112',
      aplimit: 'max',
      format: 'json',
      apfilterredir: 'nonredirects',
    };

    return this.wikiRequestService
      .queryAllPagesPromise<WikiPageSlim>('apcontinue', 'allpages', properties)
      .then((pages) =>
        pages.map((p) => ({ pageid: p.pageid, title: p.title, redirects: [] }))
      );
  }

  async dumpNewsPageList() {
    this.logger.log('Dump news page list');
    const pages = await this.fetchNewsPageList();
    this.logger.log(`Dump news page list - ${pages.length} articles found`);

    // The Update namespace is not part of the main dump, so seed the WikiPage
    // rows here. Once they exist with null text, `dumpPagesWithMissingContent`
    // will fetch their bodies on the next pass.
    await this.upsertWikiPages(
      pages.map((p) => ({ id: p.pageid, title: p.title, namespace: 112 }))
    );
    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.NEWS
    );
    await this.saveFile(ALL_NEWS_PAGE_LIST, pages);
    this.logger.log('Dump news page list - Completed');
  }

  getNews(): WikiPageSlim[] {
    return this.getPageList(ALL_NEWS_PAGE_LIST);
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

  /**
   * Fetches all pages transcluding {{Recipe}}. This captures recipes that live
   * on skill pages and other non-item pages, expanding coverage beyond items.
   */
  fetchRecipePageList(): Promise<WikiPageSlim[]> {
    return this.fetchTemplatePageList('Recipe');
  }

  async dumpRecipePageList() {
    this.logger.log('Dump recipe page list');
    const pages = await this.fetchRecipePageList();
    this.logger.log('Dump recipe page list - Completed');

    await this.addTag(
      pages.map((p) => p.pageid),
      PageTags.RECIPE
    );
    await this.saveFile(ALL_RECIPES_PAGE_LIST, pages);
  }

  getRecipes(): WikiPageSlim[] {
    return this.getPageList(ALL_RECIPES_PAGE_LIST);
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

  /**
   * Inserts slim WikiPage rows (id + title + namespace) for pages that live
   * outside the main namespace and therefore aren't part of the bulk XML dump.
   * The remaining fields (text, revisionId, ...) are filled in later by the
   * content dumper.
   */
  private async upsertWikiPages(
    pages: { id: number; title: string; namespace: number }[]
  ): Promise<void> {
    if (pages.length === 0) return;
    try {
      await this.db.batch(
        // @ts-ignore - drizzle batch typing is overly strict across versions
        pages.map((page) =>
          this.db
            .insert(WikiPage)
            .values({
              id: page.id,
              title: page.title,
              namespace: page.namespace,
            })
            .onConflictDoUpdate({
              target: WikiPage.id,
              set: { title: page.title, namespace: page.namespace },
            })
        )
      );
    } catch (e) {
      // A failed batch shouldn't abort the whole dump; rows may already exist.
      this.logger.error(e);
    }
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
