import { Injectable, Logger } from '@nestjs/common';
import axios from 'axios';
import { load } from 'cheerio';
import * as FormData from 'form-data';
import * as fs from 'fs';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import path from 'path';
import { WIKI_PAGES_FOLDER } from '../../constants/paths';
import { DatabaseService } from '../database/database.service';
import { WikiPage } from '../database/schema';
import {
  WikiPageWithContent,
  WikiRequestService,
} from '../wiki/wikiRequest.service';
import { PageListDumper } from './page-list.dumper';

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
    this.parseWikiDump();
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

  async dumpAllWikiPagesFast(): Promise<void> {
    const pageList = this.PageListDumper.getWikiPageList();
    const pageTitles = pageList.map((p) => p.title).join('\n');
    fs.writeFileSync('./page-titles.txt', pageTitles);
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
      console.log('Got response');

      this.logger.log(
        `Export successful. Response size: ${response.data.length} bytes`
      );

      // Create output directory if it doesn't exist
      fs.mkdirSync(this.outputDir, { recursive: true });

      // Save the raw XML response
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const outputPath = path.join(
        this.outputDir,
        `wiki-export-${timestamp}.xml`
      );
      writeFileSync(outputPath, Buffer.from(response.data));
      this.logger.log(`Saved XML export to: ${outputPath}`);
    } catch (error) {
      this.logger.error('Failed to export wiki pages:', error.message, error);
    }
  }
  private async parseWikiDump() {
    await new Promise((r) => setTimeout(r, 1000));
    // Todo: Get the dump from the latest file / query
    const content = readFileSync(
      './output/wiki-export-2025-04-15T01-21-04-783Z.xml',
      'utf-8'
    );
    const db = this.DatabaseService.getDb();
    const dom = load(content);
    const total = dom('page').length;

    // Map all pages to entities
    const pageEntities = Array.from(dom('page')).map((pageThing, i) => {
      if (i % 1000 === 0) {
        console.log(`Processed ${i} / ${total} pages`);
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
        await db.batch(
          // @ts-ignore
          chunk.map((page) =>
            db.insert(WikiPage).values(page).onConflictDoUpdate({
              target: WikiPage.id,
              set: page,
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

    writeFileSync(this.getPathFromPageId(pageId), JSON.stringify(newPage));
  }

  public async getDBPageFromId(
    pageId: number
  ): Promise<typeof WikiPage.$inferSelect> {
    const page = await this.db.query.WikiPage.findFirst({
      where: (wikiPage, { eq }) => eq(wikiPage.id, pageId),
    });
    return page;
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
