import { PageTags } from "../../constants/tags";
import { Injectable, Logger } from "@nestjs/common";
import { load } from "cheerio";
import { and, eq, inArray, isNull, ne } from "drizzle-orm";
import FormData from "form-data";
import * as fs from "fs";
import { existsSync, readFileSync, writeFileSync } from "fs";
import path from "path";
import { WIKI_PAGES_FOLDER } from "../../constants/paths";
import { DatabaseService } from "../database/database.service";
import { PageTag, WikiPage } from "../database/schema";
import { WikiPageWithContent, WikiRequestService } from "../wiki/wikiRequest.service";
import { PageListDumper } from "./page-list.dumper";

// Chunk size for batched page fetches; must match MAX_PAGEIDS_PER_REQUEST
// in WikiRequestService. Kept here as a local constant for clarity.
const PAGE_FETCH_CHUNK = 50;

interface WikiPageResponse {
  title: string;
  revid: number;
  displaytitle: string;
  text: {
    "*": string;
  };
  wikitext: {
    "*": string;
  };
  properties: { name: string; "*": string }[];
}

@Injectable()
export class PageContentDumper {
  private logger = new Logger(PageContentDumper.name);
  private readonly outputDir: string = "./output";
  private db: ReturnType<DatabaseService["getDb"]>;

  constructor(
    private PageListDumper: PageListDumper,
    private WikiRequestService: WikiRequestService,
    private DatabaseService: DatabaseService,
  ) {
    this.db = this.DatabaseService.getDb();
  }

  /**
   * Will dump all wiki pages
   */
  async dumpAllWikiPages(): Promise<void> {
    // this.dumpAllWikiPagesFast();
    await this.parseWikiDump();
    return;
    this.logger.log("Dump All Wiki Pages");
    const allPages = this.PageListDumper.getWikiPageList();
    // Todo: Use recentchanges + find the latest date to only update the ones that were changed
    const now = Date.now() / 1000;
    for (let i = 0; i < allPages.length; i++) {
      // Sleep for 1 second
      await new Promise((r) => setTimeout(r, 1000));
      if (i % 10 === 0) {
        this.logger.log(
          `Request ${i} / ${allPages.length} - ${Math.round(
            Math.round(Date.now() / 1000 - now),
          )} s elapsed`,
        );
      }

      const currentPage = allPages[i];
      try {
        await this.dumpWikiPageById(currentPage.pageid);
      } catch (e) {
        this.logger.error(e);
      }
    }
    this.logger.log("Dump All Wiki Pages: Completed");
  }

  /**
   * This uses the special:export to dump all the pages via one request.
   * You might have to update the wpEditToken from the browser / root page.
   * This downloads a fairly large file with content of all pages, but only the raw wiki source, not the html output / aliases, so it's not fully complete.
   */
  async dumpAllWikiPagesFast(): Promise<void> {
    const pageList = this.PageListDumper.getWikiPageList();
    const pageTitles = pageList.map((p) => p.title).join("\n");
    const formData = new FormData();
    formData.append("pages", pageTitles);
    formData.append("curonly", "1"); // Only get current revision
    formData.append("templates", "1"); // Include templates
    formData.append("wpDownload", "1"); // Request download
    formData.append(
      "wpEditToken",
      // Todo: Find out where to get this programatically
      "",
    );

    const response = await this.WikiRequestService.post<string>(
      "/w/Special:Export",
      formData,
      formData.getHeaders(),
    );
    if (!response) {
      this.logger.error("Failed to export wiki pages: no response");
      return;
    }

    this.logger.log(`Export successful. Response size: ${response.length} bytes`);

    // Create output directory if it doesn't exist
    fs.mkdirSync(this.outputDir, { recursive: true });

    // Save the raw XML response
    const outputPath = path.join(this.outputDir, `wiki-export.xml`);
    writeFileSync(outputPath, Buffer.from(response));
    this.logger.log(`Saved XML export to: ${outputPath}`);
  }

  async dumpAllPages() {
    this.logger.log(`Start: Dumping All pages`);
    const toUpdate = await this.db
      .select({ id: WikiPage.id })
      .from(WikiPage)
      .where(ne(WikiPage.revisionId, WikiPage.fullfetchRevisionId));

    this.logger.debug(`Dumping All pages: ${toUpdate.length} pages to update!`);
    await this.dumpPagesByIds(
      toUpdate.map((p) => p.id),
      "Dumping All pages",
    );

    this.logger.log(`Done: Dumping All pages`);
  }

  async dumpMonstersPages() {
    this.logger.log(`Start: Dumping monster pages`);
    const monsterPages = await this.db
      .select({ id: PageTag.wikiPageId })
      .from(PageTag)
      .where(eq(PageTag.tag, PageTags.MONSTER));

    await this.dumpPagesByIds(
      monsterPages.map((p) => p.id),
      "Dumping monster pages",
    );

    this.logger.log(`Done: Dumping monster pages`);
  }

  async dumpPagesWithMissingContent() {
    this.logger.log(`Start: Dumping pages with missing text`);
    const toUpdate = await this.db
      .select({ id: WikiPage.id })
      .from(WikiPage)
      .where(isNull(WikiPage.text));

    this.logger.debug(`Found ${toUpdate.length} pages with missing text`);
    await this.dumpPagesByIds(
      toUpdate.map((p) => p.id),
      "Dumping missing-text pages",
    );

    this.logger.log(`Done: Dumping pages with missing text`);
  }

  /**
   * Fetch content for the given page IDs in batches of
   * {@link PAGE_FETCH_CHUNK} (≤50 per API request) and persist each batch
   * before moving on. Pages whose stored revision already matches their last
   * full-fetch revision are skipped. Throttling is handled centrally in
   * {@link WikiRequestService}.
   */
  async dumpPagesByIds(pageIds: number[], label = "Dumping pages"): Promise<WikiPageWithContent[]> {
    if (pageIds.length === 0) return [];

    // Chunk the "already up to date?" check to stay under SQLite's 999-variable
    // limit. Each inArray value is one bound variable, so 500 per chunk is safe.
    const upToDateSet = new Set<number>();
    const CHECK_CHUNK = 500;
    for (let i = 0; i < pageIds.length; i += CHECK_CHUNK) {
      const chunk = pageIds.slice(i, i + CHECK_CHUNK);
      const rows = await this.db
        .select({ id: WikiPage.id })
        .from(WikiPage)
        .where(
          and(
            inArray(WikiPage.id, chunk),
            eq(WikiPage.revisionId, WikiPage.fullfetchRevisionId),
          ),
        );
      for (const r of rows) upToDateSet.add(r.id);
    }
    const toFetch = pageIds.filter((id) => !upToDateSet.has(id));

    if (toFetch.length === 0) {
      this.logger.debug(`${label}: nothing to do (${pageIds.length} already up to date)`);
      return [];
    }

    const allFetched: WikiPageWithContent[] = [];
    for (let i = 0; i < toFetch.length; i += PAGE_FETCH_CHUNK) {
      const chunk = toFetch.slice(i, i + PAGE_FETCH_CHUNK);
      const fetched = await this.WikiRequestService.queryPagesByIds(chunk);
      await this.persistPages(fetched);
      allFetched.push(...fetched);
      this.logger.debug(
        `${label}: ${i + chunk.length} / ${toFetch.length} (fetched ${fetched.length})`,
      );
    }
    return allFetched;
  }

  private async persistPages(pages: WikiPageWithContent[]): Promise<void> {
    if (pages.length === 0) return;
    try {
      await this.db.batch(
        // @ts-expect-error - drizzle batch typing is overly strict across versions
        pages
          .filter((p) => p.rawContent || p.content)
          .map((page) => {
            const updates: Record<string, unknown> = {
              text: page.rawContent,
              revisionId: page.revid,
              fullfetchRevisionId: page.revid,
            };
            // Only overwrite html when we actually fetched it (batched
            // queryPagesByIds intentionally returns empty content).
            if (page.content) {
              updates.html = page.content;
            }
            return this.db
              .update(WikiPage)
              .set(updates as never)
              .where(eq(WikiPage.id, page.pageid));
          }),
      );
      this.logger.debug(`Persisted ${pages.length} pages`);
    } catch (e) {
      this.logger.error("Error saving fetched pages to db!", e);
    }
  }

  async parseWikiDump() {
    await new Promise((r) => setTimeout(r, 1000));
    const outputPath = path.join(this.outputDir, `wiki-export.xml`);
    // Todo: Get the dump from the latest file / query
    const content = readFileSync(outputPath, "utf-8");
    const dom = load(content);
    const total = dom("page").length;

    // Map all pages to entities
    const pageEntities = Array.from(dom("page")).map((pageThing, i) => {
      if (i === 0 || i % 1000 === 0) {
        this.logger.log(`Processed ${i} / ${total} pages`);
      }

      const page = load(pageThing);
      const title = page("title").text();
      const pageId = page("id").first().text();
      const revision = page("revision>id").text();
      const parentId = page("revision>parentid").first().text();
      const timestamp = new Date(page("revision>timestamp").first().text());
      const content = page("text").text();

      return {
        id: Number(pageId),
        title: title,
        revisionId: Number(revision),
        parentId: parentId ? Number(parentId) : null,
        timestamp,
        text: content,
      } as Partial<typeof WikiPage.$inferSelect> & typeof WikiPage.$inferInsert;
    });

    // Bulk insert/update
    try {
      // Split into chunks of 1000 to avoid hitting SQLite limits
      const chunkSize = 1000;
      for (let i = 0; i < pageEntities.length; i += chunkSize) {
        const chunk = pageEntities.slice(i, i + chunkSize);
        await this.db.batch(
          // @ts-ignore
          chunk.map((page) =>
            this.db
              .insert(WikiPage)
              .values(page)
              .onConflictDoUpdate({
                target: WikiPage.id,
                set: {
                  id: page.id,
                  title: page.title,
                  revisionId: page.revisionId,
                  parentId: page.parentId,
                  text: page.text,
                  timestamp: page.timestamp,
                },
              }),
          ),
        );
        console.log(
          `Processed chunk ${i / chunkSize + 1} of ${Math.ceil(pageEntities.length / chunkSize)}`,
        );
      }
      console.log("Done!");
    } catch (e) {
      console.error("Bulk insert/update failed:", e);
    }
  }

  async dumpWikiPageById(pageId: number) {
    const [currentPage] = await this.db.select().from(WikiPage).where(eq(WikiPage.id, pageId));
    if (!currentPage || currentPage.revisionId === currentPage.fullfetchRevisionId) {
      this.logger.verbose(
        `Not refreshing page: ${currentPage?.title} (${pageId}) Already have latest version!`,
      );
      return;
    }
    // Redirects/aliases are resolved in bulk by PageListDumper.dumpRedirectList;
    // no per-page redirect lookup is needed here.
    const response = await this.WikiRequestService.query<{
      parse: WikiPageResponse;
    }>({
      action: "parse",
      pageid: pageId.toString(),
      format: "json",
      prop: "properties|wikitext|displaytitle|subtitle|revid|text",
    }).catch((e) => this.logger.error(e));
    if (!response) return;
    const result = response.parse as WikiPageResponse;

    // The page title contains some HTML title tag for some reason: Removing for clarity
    result.displaytitle = result.displaytitle
      .replaceAll(/<.*?>/g, "")
      .replace(/&#(\d+);/g, function (match, dec) {
        return String.fromCharCode(dec);
      });
    const newPage: WikiPageWithContent = {
      pageid: pageId,
      pagename: result.title,
      title: result.displaytitle,
      displaytitle: result.displaytitle,
      revid: result.revid,
      properties: result.properties.map((p) => ({
        name: p.name,
        value: p["*"],
      })),
      content: result.text["*"],
      rawContent: result.wikitext["*"],
    };

    // writeFileSync(this.getPathFromPageId(pageId), JSON.stringify(newPage));
    return newPage;
  }

  public async getDBPageFromId(pageId: number): Promise<typeof WikiPage.$inferSelect | undefined> {
    const pages = await this.db.select().from(WikiPage).where(eq(WikiPage.id, pageId)).limit(1);
    return pages?.[0];
  }

  public getPageFromId(pageId: number): WikiPageWithContent | null {
    const candidatePath = this.getPathFromPageId(pageId);
    if (!existsSync(candidatePath)) {
      return null;
    }

    const pageContent = readFileSync(candidatePath, "utf8");
    let parsed = null;
    try {
      parsed = JSON.parse(pageContent);
    } catch (e) {
      this.logger.warn("Page has invalid content", pageId, e);
    }
    return parsed;
  }

  private getPathFromPageId(pageId: number): string {
    return `${WIKI_PAGES_FOLDER}/${pageId}.json`;
  }
}
