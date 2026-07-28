import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_NEWS } from "../../constants/paths";
import { PageTags } from "../../constants/tags";
import { NewsArticle } from "../../types";
import { extractTemplate, parseTemplateFields } from "../../utils/brace-utils";
import { parseWikitext } from "../../utils/wikitext-parser";
import { wikiString } from "../../utils/wiki-coercion";
import { PageContentDumper, PageListDumper } from "../dumpers";

/** Namespace prefix stripped from every `Update:` page title. */
const UPDATE_PREFIX = "Update:";
/** Wiki origin used to build canonical article URLs. */
const WIKI_ORIGIN = "https://oldschool.runescape.wiki";

/**
 * Parses the `{{Update|date=...|url=...|category=...}}` template from a page
 * into a lower-cased key → value map. Returns an empty object when the page
 * carries no Update template (e.g. the placeholder `Update:None`).
 */
export function parseUpdateTemplate(pageText: string): Record<string, string> {
  const bodies = extractTemplate(pageText, "Update");
  if (bodies.length === 0) return {};
  return parseTemplateFields(bodies[0]);
}

/**
 * Renders a newspost body to a readable markdown-ish string. Walks each wtf
 * section, emitting `#` headings (by nesting depth) followed by the section's
 * text. MediaWiki magic words (`__TOC__`, `__NOTOC__`, ...) are stripped first.
 */
export function renderNewsBody(wikitext: string): string {
  const cleaned = wikitext.replace(/__[A-Z]+__/g, "");
  const { doc } = parseWikitext(cleaned);

  const parts: string[] = [];
  for (const section of doc.sections()) {
    const sectionTitle = section.title()?.trim();
    if (sectionTitle) {
      const level = Math.min(6, (section.depth() ?? 0) + 1);
      parts.push(`${"#".repeat(level)} ${sectionTitle}`);
    }
    const sectionText = section.text({})?.trim();
    if (sectionText) parts.push(sectionText);
  }
  return parts.join("\n\n").trim();
}

/**
 * Pure extractor: turns a raw `Update:` page into a {@link NewsArticle}.
 * Returns `null` when the page has no `{{Update}}` template (not a newspost).
 */
export function parseNewsFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[],
  pageId: number,
): NewsArticle | null {
  const params = parseUpdateTemplate(pageText);
  if (Object.keys(params).length === 0) return null;

  const title = pageTitle.replace(/^Update:/, "").trim();
  const date = wikiString(params.date);

  let dateIso = "";
  if (date) {
    const parsed = new Date(date);
    if (!Number.isNaN(parsed.getTime())) {
      dateIso = parsed.toISOString();
    }
  }

  return {
    pageId,
    title,
    aliases: pageAliases,
    date,
    dateIso,
    url: wikiString(params.url),
    category: wikiString(params.category).toLowerCase(),
    wikiUrl: `${WIKI_ORIGIN}/w/?curid=${pageId}`,
    body: renderNewsBody(pageText),
  };
}

@Injectable()
export class NewsExtractor {
  private logger = new Logger(NewsExtractor.name);
  private cachedNews: NewsArticle[] | null = null;

  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
  ) {}

  /**
   * Extracts every tagged newspost into `data/news/all-news.json`, sorted
   * newest-first. Pages without an `{{Update}}` template are skipped.
   */
  public async extractAllNews(): Promise<NewsArticle[]> {
    this.logger.log("Start: Extracting news");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.NEWS);
    const length = pages.length;
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

    this.logger.log(`Done: Extracting news (${news.length} articles)`);
    return news;
  }

  /**
   * In-memory access to the last extracted news list, lazily loaded from
   * `data/news/all-news.json`. Returns `null` if the file doesn't exist yet.
   */
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
    return parseNewsFromContent(page.text, page.title, page.aliases || [], pageId);
  }
}
