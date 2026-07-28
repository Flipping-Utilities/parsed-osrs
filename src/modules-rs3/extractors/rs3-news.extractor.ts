import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_NEWS } from "../../constants/rs3-paths";
import { NewsArticle } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseNewsFromContent } from "../../modules/extractors/news.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/**
 * Origin of the RS3 wiki. The OSRS `parseNewsFromContent` hardcodes
 * `https://oldschool.runescape.wiki` into `wikiUrl`; we rewrite the host in
 * post-processing so RS3 article URLs point at the right site.
 */
const RS3_WIKI_HOST = "runescape.wiki";
const OSRS_WIKI_HOST = "oldschool.runescape.wiki";

/** RS3 counterpart of {@link NewsExtractor}. */
@Injectable()
export class Rs3NewsExtractor {
  private logger = new Logger(Rs3NewsExtractor.name);
  private cachedNews: NewsArticle[] | null = null;

  constructor(
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllNews(): Promise<NewsArticle[]> {
    this.logger.log("Start: Extracting news (RS3)");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.NEWS);
    const news: NewsArticle[] = [];
    let i = 0;
    for (const page of pages) {
      if (i++ % 50 === 0) {
        // this.logger.debug(`News: ${i}/${length}`);
      }
      const article = await this.extractNewsFromPageId(page.id);
      if (article) news.push(article);
    }

    news.sort((a, b) => (b.dateIso || "").localeCompare(a.dateIso || ""));
    if (news.length) {
      writeFileSync(ALL_NEWS, JSON.stringify(news, null, 2));
    }

    this.logger.log(`Done: Extracting news (RS3) (${news.length} articles)`);
    return news;
  }

  public getAllNews(): NewsArticle[] | null {
    if (!this.cachedNews) {
      if (!existsSync(ALL_NEWS)) {
        return null;
      }
      try {
        this.cachedNews = JSON.parse(readFileSync(ALL_NEWS, "utf8"));
      } catch (e) {
        this.logger.warn("all-news.json has invalid content", e);
      }
    }
    return this.cachedNews;
  }

  private async extractNewsFromPageId(pageId: number): Promise<NewsArticle | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    const article = parseNewsFromContent(page.text, page.title, page.aliases || [], pageId);
    if (article?.wikiUrl) {
      article.wikiUrl = article.wikiUrl.replace(OSRS_WIKI_HOST, RS3_WIKI_HOST);
    }
    return article;
  }
}
