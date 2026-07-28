import { Injectable, Logger } from "@nestjs/common";
import { eq, inArray } from "drizzle-orm";
import { existsSync, readFileSync, writeFileSync } from "fs";
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
  ALL_QUEST_GUIDES_PAGE_LIST,
  ALL_ACTIVITIES_PAGE_LIST,
  ALL_MUSIC_PAGE_LIST,
  GE_ITEM_PAGE_LIST,
  WIKI_PAGE_LIST,
} from "../../constants/rs3-paths";
import { PageTags } from "../../constants/tags";
import { Rs3DatabaseService } from "../database/rs3-database.service";
import { PageTag, WikiPage } from "../../modules/database/schema";
import { WikiPageSlim } from "../../modules/wiki/wikiRequest.service";
import { Rs3WikiRequestService } from "../wiki/rs3-wiki-request.service";

// RS3 wiki uses ns=100 for the `Update:` namespace — NOT ns=112 (which is
// Exchange:) and NOT ns=114 (which doesn't exist). Verified via
// `action=query&meta=siteinfo&siprop=namespaces`.
const RS3_UPDATE_NAMESPACE = "100";

/**
 * RS3 counterpart of {@link PageListDumper}.
 *
 * Behaviour is intentionally identical to the OSRS dumper — same category
 * walks, same tagging, same redirect-merge algorithm. The only differences:
 *
 * - Talks to {@link Rs3WikiRequestService} (targeting `runescape.wiki`)
 * - Persists to {@link Rs3DatabaseService} (separate SQLite file)
 * - Reads/writes page-list JSON files under `data/rs3/...`
 * - Uses ns=114 for the `Update:` newspost namespace
 *
 * Extractor-level RS3 markup differences (different infoboxes, absent
 * `{{LocLine}}`, etc.) are handled by the extractors, not here. This dumper
 * just records page IDs + tags.
 */
@Injectable()
export class Rs3PageListDumper {
  private logger: Logger = new Logger(Rs3PageListDumper.name);
  private db: ReturnType<Rs3DatabaseService["getDb"]>;

  constructor(
    private readonly wikiRequestService: Rs3WikiRequestService,
    private readonly databaseService: Rs3DatabaseService,
  ) {
    this.db = this.databaseService.getDb();
  }

  async fetchWikiPageList(): Promise<WikiPageSlim[]> {
    const properties = {
      action: "query",
      list: "allpages",
      aplimit: "max",
      format: "json",
      apfilterredir: "nonredirects",
      apminsize: "5",
    };

    const pages = await this.wikiRequestService.queryAllPagesPromise<WikiPageSlim>(
      "apcontinue",
      "allpages",
      properties,
    );
    return pages.map((p) => ({
      pageid: p.pageid,
      title: p.title,
      redirects: [],
    }));
  }

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
   * RS3 counterpart of `PageListDumper.dumpRedirectList`. Walks every wiki_page
   * row in the RS3 DB, asks the RS3 wiki for pages redirecting to it, and
   * merges the new aliases into the row. Aliases change slowly — gated by
   * `SKIP_REDIRECT_REFRESH=true` in the daily cron so only the weekly run
   * pays the ~30–45 minute cost.
   *
   * Algorithm matches the OSRS dumper: chunked title lookup
   * (REDIRECT_TITLES_PER_REQUEST = 50) using `prop=redirects&rdlimit=max`,
   * merged into per-page alias sets via `mergeRedirects` from the OSRS module
   * (pure function, game-agnostic).
   */
  async dumpRedirectList(): Promise<void> {
    // Reuse the OSRS pure merge helper — it's just a Map-based diff, no wiki
    // coupling. Imported lazily so test fixtures don't pull the OSRS module.
    const { mergeRedirects } = await import(
      "../../modules/dumpers/page-list.dumper"
    );

    this.logger.log("Start: Dumping redirect list (RS3)");
    const allPages = await this.getWikiPageListDB();

    const REDIRECT_TITLES_PER_REQUEST = 50;
    const REDIRECT_DB_BATCH_SIZE = 1000;
    const allTitles = allPages.map((p) => p.title);
    const totalTitleChunks = Math.ceil(
      allTitles.length / REDIRECT_TITLES_PER_REQUEST,
    );

    type WikiRedirectResponse = {
      pageid: number;
      title: string;
      redirects?: Array<{ pageid: number; ns: number; title: string }>;
    };

    const responses: WikiRedirectResponse[] = [];
    for (
      let i = 0, chunkIdx = 0;
      i < allTitles.length;
      i += REDIRECT_TITLES_PER_REQUEST, chunkIdx++
    ) {
      if (chunkIdx % 20 === 0) {
        this.logger.verbose(
          `Querying redirect chunk ${chunkIdx + 1} / ${totalTitleChunks}`,
        );
      }
      const titles = allTitles
        .slice(i, i + REDIRECT_TITLES_PER_REQUEST)
        .join("|");
      const chunkResults =
        await this.wikiRequestService.queryAllPagesPromise<WikiRedirectResponse>(
          "rdcontinue",
          "pages",
          {
            action: "query",
            format: "json",
            prop: "redirects",
            rdlimit: "max",
            titles,
          },
        );
      responses.push(...chunkResults);
    }

    const toUpdate = mergeRedirects(allPages, responses);
    this.logger.verbose(
      `${toUpdate.length} / ${allPages.length} pages have new aliases to persist`,
    );

    const totalDbChunks = Math.ceil(toUpdate.length / REDIRECT_DB_BATCH_SIZE);
    for (let i = 0; i < toUpdate.length; i += REDIRECT_DB_BATCH_SIZE) {
      const chunk = toUpdate.slice(i, i + REDIRECT_DB_BATCH_SIZE);
      await this.db.batch(
        // @ts-expect-error - drizzle batch typing is overly strict across versions
        chunk.map(({ id, aliases }) =>
          this.db
            .update(WikiPage)
            .set({ aliases })
            .where(eq(WikiPage.id, id)),
        ),
      );
      const chunkNo = Math.floor(i / REDIRECT_DB_BATCH_SIZE) + 1;
      this.logger.debug(
        `Persisted redirect chunk ${chunkNo} / ${totalDbChunks} (${chunk.length} rows)`,
      );
    }

    this.logger.log("End: Dumping redirect list (RS3)");
  }

  async fetchAllItemPageList(category = "Items"): Promise<WikiPageSlim[]> {
    this.logger.log("Dump all item page list");

    const properties = {
      action: "query",
      list: "categorymembers",
      cmtitle: `Category:${category}`,
      cmlimit: "max",
      format: "json",
    };

    const pages = await this.wikiRequestService.queryAllPagesPromise<WikiPageSlim>(
      "cmcontinue",
      "categorymembers",
      properties,
    );

    this.logger.log("Dump all item page list - Completed");

    return pages
      .map((p) => ({
        pageid: p.pageid,
        title: p.title,
        redirects: [],
      }))
      .filter((page) => !page.title.startsWith("Category:"));
  }

  /**
   * RS3 has a `Category:Grand Exchange items` (unlike what was previously
   * assumed) — this returns its members so GE-tracked items can be tagged.
   */
  fetchGEItemPageList(): Promise<WikiPageSlim[]> {
    return this.fetchAllItemPageList("Grand Exchange items");
  }

  async dumpAllItemPageList(): Promise<void> {
    const pages = await this.fetchAllItemPageList();
    await this.registerAndTagPages(pages, PageTags.ITEM);
  }

  getAllItems(): WikiPageSlim[] {
    return this.getPageList(ALL_ITEM_PAGE_LIST);
  }

  async dumpGEItemPageList(): Promise<void> {
    this.logger.log("Dump GE item page list");
    const pages = await this.fetchGEItemPageList();
    await this.registerAndTagPages(pages, PageTags.GE_ITEM);
    await this.saveFile(GE_ITEM_PAGE_LIST, pages);
  }

  getGEItems(): WikiPageSlim[] {
    return this.getPageList(GE_ITEM_PAGE_LIST);
  }

  async fetchItemSetsPageList() {
    return this.fetchAllItemPageList("Item_sets");
  }
  async dumpItemSetsPageList() {
    this.logger.log("Dump item set page list");
    const pages = await this.fetchItemSetsPageList();
    this.logger.log("Dump item set page list - Completed");
    await this.registerAndTagPages(pages, PageTags.SET);
  }

  getItemSets(): WikiPageSlim[] {
    return this.getPageList(ALL_SETS_PAGE_LIST);
  }

  async fetchShopPageList() {
    return this.fetchAllItemPageList("Shops");
  }
  async dumpShopPageList() {
    this.logger.log("Dump shop page list");
    const pages = await this.fetchShopPageList();
    this.logger.log("Dump shop page list - Completed");
    await this.registerAndTagPages(pages, PageTags.SHOP);
  }

  getShops(): WikiPageSlim[] {
    return this.getPageList(ALL_SHOPS_PAGE_LIST);
  }

  async fetchMonstersPageList() {
    // RS3 uses `Category:Bestiary` (not `Category:Monsters` which has 0 pages).
    return this.fetchAllItemPageList("Bestiary");
  }

  async dumpMonstersPageList() {
    this.logger.log("Dump monster page list");
    const pages = await this.fetchMonstersPageList();
    await this.registerAndTagPages(pages, PageTags.MONSTER);
  }

  getMonsters(): WikiPageSlim[] {
    return this.getPageList(ALL_MONSTERS_PAGE_LIST);
  }

  async fetchPrayersPageList() {
    return this.fetchAllItemPageList("Prayers");
  }

  async dumpPrayersPageList() {
    this.logger.log("Dump prayer page list");
    const pages = await this.fetchPrayersPageList();
    await this.registerAndTagPages(pages, PageTags.PRAYER);
  }

  getPrayers(): WikiPageSlim[] {
    return this.getPageList(ALL_PRAYERS_PAGE_LIST);
  }

  async fetchSpellsPageList() {
    return this.fetchAllItemPageList("Spells");
  }

  async dumpSpellsPageList() {
    this.logger.log("Dump spell page list");
    const pages = await this.fetchSpellsPageList();
    await this.registerAndTagPages(pages, PageTags.SPELL);
  }

  getSpells(): WikiPageSlim[] {
    return this.getPageList(ALL_SPELLS_PAGE_LIST);
  }

  fetchLocationPageList(): Promise<WikiPageSlim[]> {
    return this.fetchTemplatePageList("Infobox Location");
  }

  async dumpLocationPageList() {
    this.logger.log("Dump location page list");
    const pages = await this.fetchLocationPageList();
    await this.registerAndTagPages(pages, PageTags.LOCATION);
    await this.saveFile(ALL_LOCATIONS_PAGE_LIST, pages);
  }

  getLocations(): WikiPageSlim[] {
    return this.getPageList(ALL_LOCATIONS_PAGE_LIST);
  }

  async fetchInfoboxPageList(template: string) {
    return this.fetchTemplatePageList(template);
  }

  async dumpNpcPageList() {
    this.logger.log("Dump NPC page list");
    const pages = await this.fetchInfoboxPageList("Infobox NPC");
    await this.registerAndTagPages(pages, PageTags.NPC);
  }

  getNpcs(): WikiPageSlim[] {
    return this.getPageList(ALL_NPCS_PAGE_LIST);
  }

  async dumpSceneryPageList() {
    this.logger.log("Dump scenery page list");
    const pages = await this.fetchInfoboxPageList("Infobox Scenery");
    await this.registerAndTagPages(pages, PageTags.SCENERY);
  }

  getScenery(): WikiPageSlim[] {
    return this.getPageList(ALL_SCENERY_PAGE_LIST);
  }

  async dumpQuestPageList() {
    this.logger.log("Dump quest page list");
    const pages = await this.fetchInfoboxPageList("Infobox Quest");
    await this.registerAndTagPages(pages, PageTags.QUEST);
  }

  getQuests(): WikiPageSlim[] {
    return this.getPageList(ALL_QUESTS_PAGE_LIST);
  }

  async fetchQuestGuidePageList(): Promise<WikiPageSlim[]> {
    const pages = await this.fetchTemplatePageList("Quick Guide");
    return pages.filter((p) => /\/Quick guide$/i.test(p.title));
  }

  async dumpQuestGuidePageList() {
    this.logger.log("Dump quest guide page list");
    const pages = await this.fetchQuestGuidePageList();
    await this.registerAndTagPages(pages, PageTags.QUEST_GUIDE);
    await this.saveFile(ALL_QUEST_GUIDES_PAGE_LIST, pages);
  }

  getQuestGuides(): WikiPageSlim[] {
    return this.getPageList(ALL_QUEST_GUIDES_PAGE_LIST);
  }

  async dumpActivityPageList() {
    this.logger.log("Dump activity page list");
    const pages = await this.fetchInfoboxPageList("Infobox Activity");
    await this.registerAndTagPages(pages, PageTags.ACTIVITY);
  }

  getActivities(): WikiPageSlim[] {
    return this.getPageList(ALL_ACTIVITIES_PAGE_LIST);
  }

  async dumpMusicPageList() {
    this.logger.log("Dump music page list");
    const pages = await this.fetchInfoboxPageList("Infobox Music");
    await this.registerAndTagPages(pages, PageTags.MUSIC);
    await this.saveFile(ALL_MUSIC_PAGE_LIST, pages);
  }

  getMusic(): WikiPageSlim[] {
    return this.getPageList(ALL_MUSIC_PAGE_LIST);
  }

  /**
   * Fetches every page in the RS3 `Update:` namespace (ns=114). These are the
   * historical Jagex newsposts. Note: OSRS uses ns=112 for the same namespace
   * name — the index differs because the two wikis were set up independently.
   */
  fetchNewsPageList(): Promise<WikiPageSlim[]> {
    const properties = {
      action: "query",
      list: "allpages",
      apnamespace: RS3_UPDATE_NAMESPACE,
      aplimit: "max",
      format: "json",
      apfilterredir: "nonredirects",
    };

    return this.wikiRequestService
      .queryAllPagesPromise<WikiPageSlim>("apcontinue", "allpages", properties)
      .then((pages) => pages.map((p) => ({ pageid: p.pageid, title: p.title, redirects: [] })));
  }

  async dumpNewsPageList() {
    this.logger.log("Dump news page list");
    const pages = await this.fetchNewsPageList();
    this.logger.log(`Dump news page list - ${pages.length} articles found`);

    await this.registerAndTagPages(pages, PageTags.NEWS, Number(RS3_UPDATE_NAMESPACE));
    await this.saveFile(ALL_NEWS_PAGE_LIST, pages);
  }

  getNews(): WikiPageSlim[] {
    return this.getPageList(ALL_NEWS_PAGE_LIST);
  }

  async fetchTemplatePageList(template: string): Promise<WikiPageSlim[]> {
    const properties = {
      action: "query",
      list: "embeddedin",
      eititle: `Template:${template}`,
      eilimit: "max",
      format: "json",
    };

    const pages = await this.wikiRequestService.queryAllPagesPromise<WikiPageSlim>(
      "eicontinue",
      "embeddedin",
      properties,
    );

    return pages
      .map((p) => ({
        pageid: p.pageid,
        title: p.title,
        redirects: [],
      }))
      .filter((page) => !page.title.includes(":"));
  }

  fetchItemSpawnPageList(): Promise<WikiPageSlim[]> {
    return this.fetchTemplatePageList("ItemSpawnLine");
  }

  async dumpItemSpawnPageList() {
    this.logger.log("Dump item spawn page list");
    const pages = await this.fetchItemSpawnPageList();
    await this.registerAndTagPages(pages, PageTags.ITEM_SPAWN);
  }

  getItemSpawns(): WikiPageSlim[] {
    return this.getPageList(ALL_ITEM_SPAWNS_PAGE_LIST);
  }

  /**
   * Finds every page transcluding `{{Infobox Recipe}}` — the RS3 counterpart
   * of OSRS's `{{Recipe}}`. This template lives directly on item pages
   * (e.g. "Black dragonhide vambraces"), so the page list mirrors the
   * item-page list plus any non-item pages that document a recipe.
   */
  fetchRecipePageList(): Promise<WikiPageSlim[]> {
    return this.fetchTemplatePageList("Infobox Recipe");
  }

  async dumpRecipePageList() {
    this.logger.log("Dump recipe page list");
    const pages = await this.fetchRecipePageList();
    await this.registerAndTagPages(pages, PageTags.RECIPE);
    await this.saveFile(ALL_RECIPES_PAGE_LIST, pages);
  }

  getRecipes(): WikiPageSlim[] {
    return this.getPageList(ALL_RECIPES_PAGE_LIST);
  }

  async getPagesFromTag(tag: string): Promise<Array<typeof WikiPage.$inferSelect>> {
    const tags = await this.db.select().from(PageTag).where(eq(PageTag.tag, tag));
    const pageIds = tags.map((t) => t.wikiPageId);

    // Chunk the IN clause to stay under SQLite's 999-variable limit.
    const result: Array<typeof WikiPage.$inferSelect> = [];
    const CHUNK = 500;
    for (let i = 0; i < pageIds.length; i += CHUNK) {
      const chunk = pageIds.slice(i, i + CHUNK);
      const rows = await this.db.select().from(WikiPage).where(inArray(WikiPage.id, chunk));
      result.push(...rows);
    }
    return result;
  }

  private saveFile(path: string, content: unknown) {
    writeFileSync(path, JSON.stringify(content, null, 2));
  }

  // SQLite caps bound variables per statement at 999 by default. Each
  // upsert row uses 3 vars (id, title, namespace) → safe chunk = 300.
  // Each tag row uses 2 vars → safe chunk = 400. We use 250 for both to
  // stay well under the limit with headroom for future columns.
  private static readonly DB_BATCH_SIZE = 250;

  private async upsertWikiPages(
    pages: { id: number; title: string; namespace: number }[],
  ): Promise<void> {
    if (pages.length === 0) return;
    try {
      for (let i = 0; i < pages.length; i += Rs3PageListDumper.DB_BATCH_SIZE) {
        const chunk = pages.slice(i, i + Rs3PageListDumper.DB_BATCH_SIZE);
        await this.db.batch(
          // @ts-expect-error - drizzle batch typing is overly strict across versions
          chunk.map((page) =>
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
              }),
          ),
        );
      }
    } catch (e) {
      this.logger.error(e);
    }
  }

  /**
   * Upserts slim `wiki_page` rows for every page in the list AND tags them
   * in one shot.
   *
   * This is the RS3 equivalent of what the OSRS XML-dump import
   * (`parseWikiDump`) does — it creates the rows that
   * `dumpPagesWithMissingContent` later fills with fetched text. Without
   * this step, the category walks tag page IDs that have no corresponding
   * `wiki_page` row, so the content dumper finds nothing to fetch and the
   * extractors see zero pages.
   *
   * @param pages     Slim page list from a category/template walk.
   * @param tag       PageTags value to apply.
   * @param namespace MediaWiki namespace index (0 = main). Defaults to 0.
   *                  Pass 114 for RS3 `Update:` newsposts.
   */
  private async registerAndTagPages(
    pages: WikiPageSlim[],
    tag: string,
    namespace: number = 0,
  ): Promise<void> {
    if (pages.length === 0) return;
    await this.upsertWikiPages(
      pages.map((p) => ({ id: p.pageid, title: p.title, namespace })),
    );
    await this.addTag(
      pages.map((p) => p.pageid),
      tag,
    );
  }

  private async addTag(pagesId: number[], tag: string) {
    try {
      for (let i = 0; i < pagesId.length; i += Rs3PageListDumper.DB_BATCH_SIZE) {
        const chunk = pagesId.slice(i, i + Rs3PageListDumper.DB_BATCH_SIZE);
        await this.db.batch(
          // @ts-expect-error - drizzle batch typing is overly strict across versions
          chunk.map((pageId) =>
            this.db.insert(PageTag).values({ wikiPageId: pageId, tag }).onConflictDoNothing(),
          ),
        );
      }
    } catch (e) {
      console.error(e);
    }
  }

  private getPageList(path: string): WikiPageSlim[] {
    if (!existsSync(path)) {
      return [];
    }
    return JSON.parse(readFileSync(path, "utf-8"));
  }
}
