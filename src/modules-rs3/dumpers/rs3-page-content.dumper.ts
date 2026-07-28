import { Injectable, Logger } from "@nestjs/common";
import { load } from "cheerio";
import { and, eq, inArray, isNull, ne } from "drizzle-orm";
import FormData from "form-data";
import * as fs from "fs";
import { existsSync, readFileSync, writeFileSync } from "fs";
import path from "path";
import { WIKI_PAGES_FOLDER } from "../../constants/rs3-paths";
import { Rs3DatabaseService } from "../database/rs3-database.service";
import { WikiPage } from "../../modules/database/schema";
import { WikiPageWithContent } from "../../modules/wiki/wikiRequest.service";
import { Rs3WikiRequestService } from "../wiki/rs3-wiki-request.service";
import { Rs3PageListDumper } from "./rs3-page-list.dumper";

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

/**
 * RS3 counterpart of {@link PageContentDumper}.
 *
 * Same fetch/persist strategy as the OSRS dumper (batched `action=query`,
 * revision-skipping, missing-content sweep) but pointed at the RS3 wiki and
 * the RS3 SQLite database. OSRS dumper code is left untouched.
 */
@Injectable()
export class Rs3PageContentDumper {
  private logger: Logger = new Logger(Rs3PageContentDumper.name);
  private readonly outputDir: string = "./output-rs3";
  private db: ReturnType<Rs3DatabaseService["getDb"]>;

  constructor(
    private PageListDumper: Rs3PageListDumper,
    private WikiRequestService: Rs3WikiRequestService,
    private DatabaseService: Rs3DatabaseService,
  ) {
    this.db = this.DatabaseService.getDb();
  }

  async dumpAllWikiPages(): Promise<void> {
    await this.parseWikiDump();
  }

  /**
   * Special:Export-based bulk dump. Same approach as the OSRS dumper: POST
   * the page titles to `/w/Special:Export`, receive an XML dump, persist it
   * to the RS3 DB.
   *
   * NOTE: `wpEditToken` is currently empty — same caveat as the OSRS path.
   * Use this for first-time bulk loads; rely on the batched API fetch for
   * incremental updates.
   */
  async dumpAllWikiPagesFast(): Promise<void> {
    const pageList = this.PageListDumper.getWikiPageList();
    const pageTitles = pageList.map((p) => p.title).join("\n");
    const formData = new FormData();
    formData.append("pages", pageTitles);
    formData.append("curonly", "1");
    formData.append("templates", "1");
    formData.append("wpDownload", "1");
    formData.append("wpEditToken", "");

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

    fs.mkdirSync(this.outputDir, { recursive: true });
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
    const content = readFileSync(outputPath, "utf-8");
    const dom = load(content);
    const total = dom("page").length;

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

    try {
      const chunkSize = 1000;
      for (let i = 0; i < pageEntities.length; i += chunkSize) {
        const chunk = pageEntities.slice(i, i + chunkSize);
        await this.db.batch(
          // @ts-expect-error - drizzle batch typing is overly strict across versions
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
