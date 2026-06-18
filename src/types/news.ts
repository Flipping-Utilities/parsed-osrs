/**
 * A news article sourced from the OSRS Wiki `Update:` namespace (ns=112).
 *
 * Every page in that namespace is a historical Jagex newspost (game updates,
 * patch notes, behind the scenes, developer blogs, etc.). Each starts with a
 * `{{Update|date=...|url=...|category=...}}` template whose parameters carry the
 * original publication metadata.
 */
export interface NewsArticle {
  /** Wiki page ID of the `Update:` page. */
  pageId: number;
  /** Article title with the `Update:` namespace prefix stripped. */
  title: string;
  /** Redirect page names that resolve to this article. */
  aliases: string[];
  /** Original publication date as written on the wiki, e.g. `17 June 2026`. */
  date: string;
  /** ISO 8601 publication date (UTC midnight) for sorting/filtering. */
  dateIso: string;
  /** Original Jagex newspost URL when available (empty for very old posts). */
  url: string;
  /** Update category lower-cased from the template, e.g. `game`, `bts`. */
  category: string;
  /** Direct link to the wiki page. */
  wikiUrl: string;
  /** Rendered article body (markdown-ish: headings + paragraphs + lists). */
  body: string;
}
