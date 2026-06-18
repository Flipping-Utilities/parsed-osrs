import { Injectable, Logger } from '@nestjs/common';
import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';
import http from 'http';
import https from 'https';

export interface ApiQueryBase {
  batchcomplete: string;
  continue: {
    continue: string;
  };
  limits: unknown;
  query: unknown;
}

export interface CategorySearch extends ApiQueryBase {
  continue: {
    cmcontinue: string;
    continue: string;
    eicontinue: string;
  };
  limits: {
    categorymembers: number;
  };
  query: {
    categorymembers: WikiPageSlim[];
  };
}

export interface PageSearch extends ApiQueryBase {
  continue: {
    apcontinue: string;
    continue: string;
    eicontinue: string;
  };
  limits: {
    allpages: number;
  };
  query: {
    allpages: WikiPageSlim[];
  };
}

export interface ParsePage {
  parse: WikiPageWithContent;
}

export interface WikiPageWithContent {
  pagename: string;
  title: string;
  pageid: number;
  revid: number;
  // Html
  content: string;
  // Mediawiki text
  rawContent: string;
  displaytitle: string;
  redirects?: string[];
  properties: { name: string; value: string }[];
}

export type WikiPageSlim = Pick<
  WikiPageWithContent,
  'pageid' | 'title' | 'redirects'
>;

interface WikiPageQueryRevision {
  revid?: number;
  parentid?: number;
  timestamp?: string;
  slots?: {
    main?: { content?: string };
  };
  content?: string;
}

interface WikiPageQueryPage {
  pageid: number;
  ns: number;
  title: string;
  pagename?: string;
  displaytitle?: string;
  missing?: boolean;
  invalid?: boolean;
  revisions?: WikiPageQueryRevision[];
  properties?: { name: string; '*': string }[];
  redirects?: { pageid: number; ns: number; title: string }[];
}

interface WikiPageQueryResponse {
  batchcomplete?: string;
  continue?: Record<string, string>;
  query?: { pages: WikiPageQueryPage[] };
}

const WIKI_ORIGIN = 'https://oldschool.runescape.wiki';
const API_PATH = '/api.php';
/**
 * Minimum delay between two outgoing wiki requests, in milliseconds.
 * Override at runtime with the `WIKI_REQUEST_INTERVAL_MS` environment variable.
 */
const REQUEST_INTERVAL_MS = Number(
  process.env.WIKI_REQUEST_INTERVAL_MS ?? 1000
);
const REQUEST_TIMEOUT_MS = 30_000;
const MAX_RETRIES = 4;
// MediaWiki allows up to 50 pageids per request for anonymous/bot users
// without the `max` limit; this is a safe hard cap.
const MAX_PAGEIDS_PER_REQUEST = 50;

/**
 * All wiki-bound HTTP traffic goes through this service.
 *
 * Every request is serialized through a single promise chain so that at least
 * {@link REQUEST_INTERVAL_MS} separates two requests, no matter who initiates
 * them or from where. On top of that, transient failures (429, 5xx, timeouts)
 * are retried with exponential backoff, the underlying axios instance keeps
 * connections alive, and the User-Agent is derived centrally from
 * `DISCORD_USERNAME`.
 */
@Injectable()
export class WikiRequestService {
  private logger: Logger = new Logger(WikiRequestService.name);

  public readonly baseUrl: string = `${WIKI_ORIGIN}${API_PATH}`;

  /**
   * Process-wide throttle chain. Every scheduled request appends itself to
   * this promise so requests execute strictly one-after-another with at least
   * {@link REQUEST_INTERVAL_MS} between them.
   */
  private static throttleChain: Promise<unknown> = Promise.resolve();
  private static lastRequestAt = 0;

  private readonly client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: WIKI_ORIGIN,
      timeout: REQUEST_TIMEOUT_MS,
      maxRedirects: 5,
      httpAgent: new http.Agent({ keepAlive: true }),
      httpsAgent: new https.Agent({ keepAlive: true }),
      headers: {
        'User-Agent': WikiRequestService.buildUserAgent(),
      },
    });
  }

  private static buildUserAgent(): string {
    const id = process.env.DISCORD_USERNAME || 'anonymous';
    return `parsed-osrs wiki-scraper - ${id}`;
  }

  /**
   * Serialize a network operation through the global 1s throttle.
   * Returns a promise that resolves with the operation's result.
   */
  private schedule<T>(op: () => Promise<T>): Promise<T> {
    const run = WikiRequestService.throttleChain.then(async () => {
      const elapsed = Date.now() - WikiRequestService.lastRequestAt;
      const wait = Math.max(0, REQUEST_INTERVAL_MS - elapsed);
      if (wait > 0) {
        await new Promise((r) => setTimeout(r, wait));
      }
      // Stamp dispatch time BEFORE sending so that a failed request
      // (which throws below) still counts toward the throttle gap.
      WikiRequestService.lastRequestAt = Date.now();
      return op();
    });
    // Chain future requests behind this one. Errors are swallowed so a single
    // failure can never wedge the chain for everyone else.
    WikiRequestService.throttleChain = run.then(
      () => undefined,
      () => undefined
    );
    return run;
  }

  /**
   * Send a request through the throttled axios instance with retry/backoff
   * for transient failures (429, 5xx, ECONNABORTED). Retries re-enter
   * `schedule`, so they also respect the 1s global throttle.
   */
  private async send<T>(config: AxiosRequestConfig): Promise<T> {
    let attempt = 0;
    // eslint-disable-next-line no-constant-condition
    while (true) {
      try {
        const response = await this.schedule(() =>
          this.client.request<T>(config)
        );
        return response.data;
      } catch (error) {
        const status = (error as any)?.response?.status as number | undefined;
        const code = (error as any)?.code as string | undefined;
        const retryable =
          status === 429 ||
          (typeof status === 'number' && status >= 500 && status <= 599) ||
          code === 'ECONNABORTED' ||
          code === 'ETIMEDOUT';

        if (!retryable || attempt >= MAX_RETRIES) {
          throw error;
        }

        const retryAfterHeader = (error as any)?.response?.headers?.[
          'retry-after'
        ];
        const backoffMs = retryAfterHeader
          ? Number(retryAfterHeader) * 1000
          : Math.min(30_000, 500 * 2 ** attempt);
        this.logger.warn(
          `Wiki request failed (status=${status ?? code}, url=${
            config.url ?? API_PATH
          }); retrying in ${backoffMs}ms (attempt ${
            attempt + 1
          }/${MAX_RETRIES})`
        );
        await new Promise((r) => setTimeout(r, backoffMs));
        attempt += 1;
      }
    }
  }

  /**
   * Generic MediaWiki `action=query` / `action=parse` caller.
   * Returns `undefined` if the request fails after all retries (preserves the
   * historical lenient contract used by callers).
   */
  public async query<T>(
    params: { action: string } & Record<string, string>
  ): Promise<T | undefined> {
    try {
      return await this.send<T>({
        url: API_PATH,
        method: 'GET',
        params,
      });
    } catch (e) {
      this.logger.error(e);
      return undefined;
    }
  }

  /**
   * Fetch the raw body of an arbitrary path on the wiki origin. Used for
   * `action=raw` module/route fetches (e.g. Module:GELimits/data.json,
   * Module:Foo source). Goes through the same throttle and retry pipeline.
   *
   * @param path     Wiki path beginning with `/` (e.g. `/w/index.php`).
   * @param params   Optional query params; serialized by axios which encodes
   *                 spaces as `%20` (not `+`), matching what MediaWiki expects.
   */
  public async getRawText(
    path: string,
    params?: Record<string, string>
  ): Promise<string | undefined> {
    try {
      return await this.send<string>({
        url: path.startsWith('/') ? path : `/${path}`,
        method: 'GET',
        params,
        responseType: 'text',
        transformResponse: (d) => d,
      });
    } catch (e) {
      this.logger.error(`getRawText failed for ${path}`, e);
      return undefined;
    }
  }

  /**
   * POST arbitrary data (e.g. multipart form data for Special:Export) to a
   * wiki path. Same throttle / retry / User-Agent pipeline as everything else.
   * Returns the raw response body (string/Buffer depending on endpoint).
   */
  public async post<T = unknown>(
    path: string,
    data: unknown,
    headers: Record<string, string> = {}
  ): Promise<T | undefined> {
    try {
      return await this.send<T>({
        url: path.startsWith('/') ? path : `/${path}`,
        method: 'POST',
        data,
        headers,
        transformResponse: (d) => d as T,
      });
    } catch (e) {
      this.logger.error(`POST ${path} failed`, e);
      return undefined;
    }
  }

  public async queryAllPagesPromise<T>(
    paginationKey: 'cmcontinue' | 'apcontinue' | 'eicontinue' | 'rdcontinue',
    resultKey: 'categorymembers' | 'allpages' | 'embeddedin' | 'pages',
    params: { action: string } & Record<string, string>
  ) {
    const result: T[] = [];
    const query = this.queryAllPages<T>(paginationKey, resultKey, params);
    for await (const value of query) {
      if (!value) continue;
      if (Array.isArray(value)) {
        result.push(...value);
      } else if (resultKey === 'pages') {
        // paginated query.pages is an object map in v1 format
        result.push(...(Object.values(value as object) as T[]));
      } else {
        result.push(value as T);
      }
    }
    return result;
  }

  public queryAllPages = async function* <T>(
    this: WikiRequestService,
    paginationKey: 'cmcontinue' | 'apcontinue' | 'eicontinue' | 'rdcontinue',
    resultKey: 'categorymembers' | 'allpages' | 'embeddedin' | 'pages',
    params: { action: string } & Record<string, string>
  ): AsyncGenerator<T[]> {
    let next: string | undefined = undefined;
    let hasNext = true;
    let i = 0;
    do {
      if (i++ % 10 === 0) {
        this.logger.log(`Querying pages: ${i - 1}`);
      }
      // Only include the pagination key when we actually have a token.
      // MediaWiki's `embeddedin` (eicontinue) rejects an empty-string
      // continue with `badcontinue`, returning an empty result — which is
      // why template-transclusion page lists (locations, recipes, NPCs,
      // scenery, quests, activities, music, item spawns) came back empty.
      // `categorymembers` and `allpages` happen to tolerate the empty
      // value, which is why item/shop/monster/prayer/spell dumps worked.
      const requestParams: { action: string } & Record<string, string> = {
        ...params,
      };
      if (next !== undefined) {
        requestParams[paginationKey] = next;
      }
      const response = await this.send<PageSearch & CategorySearch>({
        url: API_PATH,
        method: 'GET',
        params: requestParams,
      });

      const err = (response as unknown as {
        error?: { code?: string; info?: string };
      }).error;
      if (err) {
        throw new Error(`Wiki API error: ${err.info ?? err.code}`);
      }

      next = response.continue?.[paginationKey] as string | undefined;
      hasNext = Boolean(next);
      const values = response.query?.[resultKey] as T[] | undefined;
      yield values ?? [];
    } while (hasNext);
    this.logger.log('Done!');
  };

  /**
   * Batched page fetch.
   *
   * Replaces the old pattern of calling `action=parse&pageid=X` once per page.
   * Uses `action=query&pageids=A|B|...` (up to {@link MAX_PAGEIDS_PER_REQUEST}
   * ids per request) to pull wikitext, revid, properties, display title and
   * redirects in one shot. Reduces request count by up to 50x and folds the
   * per-page redirect lookup into the same call.
   *
   * Note: rendered HTML (`WikiPageWithContent.content`) is intentionally NOT
   * fetched here — `action=parse` is the only MediaWiki endpoint that returns
   * rendered HTML and it does not support batching. Use {@link dumpWikiPageById}
   * for the rare pages that need HTML.
   */
  public async queryPagesByIds(
    pageIds: number[]
  ): Promise<WikiPageWithContent[]> {
    const results: WikiPageWithContent[] = [];
    for (let i = 0; i < pageIds.length; i += MAX_PAGEIDS_PER_REQUEST) {
      const chunk = pageIds.slice(i, i + MAX_PAGEIDS_PER_REQUEST);
      const data = await this.send<WikiPageQueryResponse>({
        url: API_PATH,
        method: 'GET',
        params: {
          action: 'query',
          format: 'json',
          formatversion: '2',
          pageids: chunk.join('|'),
          prop: 'revisions|properties|info|redirects',
          rvprop: 'content|ids|timestamp',
          rvslots: 'main',
          inprop: 'displaytitle|url',
          rdlimit: 'max',
        },
      });

      const pages = data.query?.pages ?? [];
      for (const page of pages) {
        if (page.missing || page.invalid || !page.revisions?.length) {
          continue;
        }
        const rev = page.revisions[0];
        const rawContent = rev?.slots?.main?.content ?? rev?.content ?? '';

        const cleanTitle = (page.displaytitle || page.title || '')
          .replaceAll(/<.*?>/g, '')
          .replace(/&#(\d+);/g, (_match, dec) => String.fromCharCode(dec));

        results.push({
          pageid: page.pageid,
          pagename: page.title,
          title: cleanTitle,
          displaytitle: cleanTitle,
          revid: rev?.revid ?? 0,
          redirects: (page.redirects ?? []).map((r) => r.title),
          properties: (page.properties ?? []).map((p) => ({
            name: p.name,
            value: p['*'],
          })),
          content: '',
          rawContent,
        });
      }
    }
    return results;
  }

  /**
   * @deprecated Redirects are now returned inline by {@link queryPagesByIds}
  and by the batched pass in `PageListDumper.dumpRedirectList`. Kept for
  compatibility only.
   */
  public async getRedirectsToPage(pageId: number): Promise<string[]> {
    const params = {
      action: 'query',
      format: 'json',
      prop: 'redirects',
      pageids: pageId,
      rdlimit: '500',
    };

    const data = await this.send<{
      continue?: unknown;
      query?: {
        pages?: {
          [pageId: string]: {
            pageid: number;
            redirects?: { pageid: number; title: string }[];
          };
        };
      };
    }>({
      url: API_PATH,
      method: 'GET',
      params,
    });

    return (
      data?.query?.pages?.[String(pageId)]?.redirects?.map((r) => r.title) ?? []
    );
  }
}
