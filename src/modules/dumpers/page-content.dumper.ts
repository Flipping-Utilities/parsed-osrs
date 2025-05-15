import { Injectable, Logger } from '@nestjs/common';
import axios from 'axios';
import { eq, ne } from 'drizzle-orm';
import { load } from 'cheerio';
import FormData from 'form-data';
import * as fs from 'fs';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import path from 'path';
import { WIKI_PAGES_FOLDER } from '../../constants/paths';
import { DatabaseService } from '../database/database.service';
import { PageTag, WikiPage } from '../database/schema';
import {
  WikiPageWithContent,
  WikiRequestService,
} from '../wiki/wikiRequest.service';
import { PageListDumper } from './page-list.dumper';
import { PageTags } from 'src/constants/tags';

interface WikiPageResponse {
  title: string;
  revid: number;
  displaytitle: string;
  text: {
    '*': string;
  };
  wikitext: {
    '*': string;
  };
  properties: { name: string; '*': string }[];
}

@Injectable()
export class PageContentDumper {
  private logger = new Logger(PageContentDumper.name);
  private readonly outputDir: string = './output';
  private db: ReturnType<DatabaseService['getDb']>;

  constructor(
    private PageListDumper: PageListDumper,
    private WikiRequestService: WikiRequestService,
    private DatabaseService: DatabaseService
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
    this.logger.log('Dump All Wiki Pages');
    const allPages = this.PageListDumper.getWikiPageList();
    // Todo: Use recentchanges + find the latest date to only update the ones that were changed
    const now = Date.now() / 1000;
    for (let i = 0; i < allPages.length; i++) {
      // Sleep for 1 second
      await new Promise((r) => setTimeout(r, 1000));
      if (i % 10 === 0) {
        this.logger.log(
          `Request ${i} / ${allPages.length} - ${Math.round(
            Math.round(Date.now() / 1000 - now)
          )} s elapsed`
        );
      }

      const currentPage = allPages[i];
      try {
        await this.dumpWikiPageById(currentPage.pageid);
      } catch (e) {
        this.logger.error(e);
      }
    }
    this.logger.log('Dump All Wiki Pages: Completed');
  }

  /**
   * This uses the special:export to dump all the pages via one request.
   * You might have to update the wpEditToken from the browser / root page.
   * This downloads a fairly large file with content of all pages, but only the raw wiki source, not the html output / aliases, so it's not fully complete.
   */
  async dumpAllWikiPagesFast(): Promise<void> {
    const pageList = this.PageListDumper.getWikiPageList();
    const pageTitles = pageList.map((p) => p.title).join('\n');
    const formData = new FormData();
    formData.append('pages', pageTitles);
    formData.append('curonly', '1'); // Only get current revision
    formData.append('templates', '1'); // Include templates
    formData.append('wpDownload', '1'); // Request download
    formData.append(
      'wpEditToken',
      // Todo: Find out where to get this programatically
      ''
    );

    try {
      const response = await axios.post(
        'https://oldschool.runescape.wiki/w/Special:Export',
        formData,
        {
          headers: {
            ...formData.getHeaders(),
            'User-Agent': `parsed-osrs 0.1 - ${process.env.DISCORD_USERNAME}`,
          },
        }
      );

      this.logger.log(
        `Export successful. Response size: ${response.data.length} bytes`
      );

      // Create output directory if it doesn't exist
      fs.mkdirSync(this.outputDir, { recursive: true });

      // Save the raw XML response
      const outputPath = path.join(this.outputDir, `wiki-export.xml`);
      writeFileSync(outputPath, Buffer.from(response.data));
      this.logger.log(`Saved XML export to: ${outputPath}`);
    } catch (error) {
      this.logger.error(
        'Failed to export wiki pages:',
        (error as any)?.message,
        error
      );
    }
  }

  async dumpAllPages() {
    this.logger.log(`Start: Dumping All pages`);
    const toUpdate = await this.db
      .select({
        id: WikiPage.id,
        revisionId: WikiPage.revisionId,
        fullfetchRevisionId: WikiPage.fullfetchRevisionId,
      })
      .from(WikiPage)
      .where(ne(WikiPage.revisionId, WikiPage.fullfetchRevisionId));

    const pageMeta: WikiPageWithContent[] = [];

    const savePages = async () => {
      try {
        await this.db.batch(
          // @ts-ignore
          pageMeta
            .filter((p) => p.content)
            .map((page) =>
              this.db
                .update(WikiPage)
                .set({
                  html: page.content,
                  fullfetchRevisionId: page.revid,
                  text: page.rawContent,
                  revisionId: page.revid,
                })
                .where(eq(WikiPage.id, page.pageid))
            )
        );
        this.logger.debug(`Updated ${pageMeta.length} pages!`);
        // Reset list
        pageMeta.length = 0;
      } catch (e) {
        this.logger.error('Error saving full pages to db!', e);
      }
    };

    let i = 0;

    this.logger.debug(`Dumping All pages: ${toUpdate.length} pages to update!`);
    let requestDelay = Promise.resolve();
    for await (const page of toUpdate) {
      if (i++ % 25 === 0) {
        this.logger.debug(`Dumping All pages: ${i} / ${toUpdate.length}`);
        await savePages();
      }
      await requestDelay;
      requestDelay = new Promise((r) => setTimeout(r, 1000));
      const wikiMetadata = await this.dumpWikiPageById(page.id);
      if (wikiMetadata) {
        pageMeta.push(wikiMetadata);
        // Wait 1 second
      } else {
        requestDelay = Promise.resolve();
      }
    }
    await savePages();

    this.logger.log(`Done: Dumping All pages`);
  }

  async dumpMonstersPages() {
    this.logger.log(`Start: Dumping monster pages`);
    const monsterPages = await this.db
      .select()
      .from(PageTag)
      .where(eq(PageTag.tag, PageTags.MONSTER));

    // Todo: Only update if the page revision id is not the page that was last fetched by the html
    // Make a col for `last_fullpage_fetch_id` and update it when we dump the full page
    // Only fetch the page if that page revision is different from the revision it was last saved from.
    const monsterPageMetadata: WikiPageWithContent[] = [];
    const saveMonsterPages = async () => {
      try {
        await this.db.batch(
          // @ts-ignore
          monsterPageMetadata
            .filter((p) => p.content)
            .map((page) =>
              this.db
                .update(WikiPage)
                .set({
                  html: page.content,
                  fullfetchRevisionId: page.revid,
                  revisionId: page.revid,
                })
                .where(eq(WikiPage.id, page.pageid))
            )
        );
        this.logger.debug(`Updated ${monsterPageMetadata.length} pages!`);
        // Reset list
        monsterPageMetadata.length = 0;
      } catch (e) {
        this.logger.error('Error inserting html to monster page!');
      }
    };

    let i = 0;

    for await (const page of monsterPages) {
      if (i++ % 100 === 99) {
        this.logger.debug(
          `Dumping monster pages: ${i} / ${monsterPages.length}`
        );
        await saveMonsterPages();
      }
      const wikiMetadata = await this.dumpWikiPageById(page.wikiPageId);
      if (wikiMetadata) {
        monsterPageMetadata.push(wikiMetadata);
        // Wait 1 second
        await new Promise((r) => setTimeout(r, 1000));
      }
    }
    await saveMonsterPages();

    this.logger.log(`Done: Dumping monster pages`);
  }

  async parseWikiDump() {
    await new Promise((r) => setTimeout(r, 1000));
    const outputPath = path.join(this.outputDir, `wiki-export.xml`);
    // Todo: Get the dump from the latest file / query
    const content = readFileSync(outputPath, 'utf-8');
    const dom = load(content);
    const total = dom('page').length;

    // Map all pages to entities
    const pageEntities = Array.from(dom('page')).map((pageThing, i) => {
      if (i === 0 || i % 1000 === 0) {
        this.logger.log(`Processed ${i} / ${total} pages`);
      }

      const page = load(pageThing);
      const title = page('title').text();
      const pageId = page('id').first().text();
      const revision = page('revision>id').text();
      const parentId = page('revision>parentid').first().text();
      const timestamp = new Date(page('revision>timestamp').first().text());
      const content = page('text').text();

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
              })
          )
        );
        console.log(
          `Processed chunk ${i / chunkSize + 1} of ${Math.ceil(
            pageEntities.length / chunkSize
          )}`
        );
      }
      console.log('Done!');
    } catch (e) {
      console.error('Bulk insert/update failed:', e);
    }
  }

  async dumpWikiPageById(pageId: number) {
    const [currentPage] = await this.db
      .select()
      .from(WikiPage)
      .where(eq(WikiPage.id, pageId));
    if (
      !currentPage ||
      currentPage.revisionId === currentPage.fullfetchRevisionId
    ) {
      this.logger.verbose(
        `Not refreshing page: ${currentPage?.title} (${pageId}) Already have latest version!`
      );
      return;
    }
    const redirects = this.WikiRequestService.getRedirectsToPage(pageId);
    let response;
    try {
      response = await this.WikiRequestService.query<{
        parse: WikiPageResponse;
      }>({
        action: 'parse',
        pageid: pageId.toString(),
        format: 'json',
        prop: 'properties|wikitext|displaytitle|subtitle|revid|text',
      }).catch((e) => this.logger.error(e));
    } catch (e) {
      this.logger.error(e);
    }
    if (!response) return;
    const result = response.parse as WikiPageResponse;

    // The page title contains some HTML title tag for some reason: Removing for clarity
    result.displaytitle = result.displaytitle
      .replaceAll(/<.*?>/g, '')
      .replace(/&#(\d+);/g, function (match, dec) {
        return String.fromCharCode(dec);
      });
    const newPage: WikiPageWithContent = {
      pageid: pageId,
      pagename: result.title,
      title: result.displaytitle,
      displaytitle: result.displaytitle,
      revid: result.revid,
      redirects: await redirects,
      properties: result.properties.map((p) => ({
        name: p.name,
        value: p['*'],
      })),
      content: result.text['*'],
      rawContent: result.wikitext['*'],
    };

    // writeFileSync(this.getPathFromPageId(pageId), JSON.stringify(newPage));
    return newPage;
  }

  public async getDBPageFromId(
    pageId: number
  ): Promise<typeof WikiPage.$inferSelect | undefined> {
    const pages = await this.db
      .select()
      .from(WikiPage)
      .where(eq(WikiPage.id, pageId))
      .limit(1);
    return pages?.[0];
  }

  public getPageFromId(pageId: number): WikiPageWithContent | null {
    const candidatePath = this.getPathFromPageId(pageId);
    if (!existsSync(candidatePath)) {
      return null;
    }

    const pageContent = readFileSync(candidatePath, 'utf8');
    let parsed = null;
    try {
      parsed = JSON.parse(pageContent);
    } catch (e) {
      this.logger.warn('Page has invalid content', pageId, e);
    }
    return parsed;
  }

  private getPathFromPageId(pageId: number): string {
    return `${WIKI_PAGES_FOLDER}/${pageId}.json`;
  }
}
