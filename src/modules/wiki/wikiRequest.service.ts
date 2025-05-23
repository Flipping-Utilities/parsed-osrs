import { Injectable, Logger } from '@nestjs/common';
import axios from 'axios';

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

@Injectable()
export class WikiRequestService {
  private logger: Logger = new Logger(WikiRequestService.name);

  public readonly baseUrl: string = 'https://oldschool.runescape.wiki/api.php';

  public async query<T>(
    params: { action: string } & Record<string, string>
  ): Promise<T | undefined> {
    if (!process.env.DISCORD_USERNAME) {
      throw new Error('DISCORD_USERNAME is not set');
    }

    const response = await axios
      .get<T>(this.baseUrl, {
        params,
        headers: {
          'User-Agent': `${process.env.DISCORD_USERNAME} - Parsed osrs`,
        },
      })
      .catch((e) => {
        this.logger.error(e);
      });

    if (response) {
      return response.data;
    }
  }

  public async queryAllPagesPromise<T>(
    paginationKey: 'cmcontinue' | 'apcontinue' | 'eicontinue' | 'rdcontinue',
    resultKey: 'categorymembers' | 'allpages' | 'embeddedin' | 'pages',
    params: { action: string } & Record<string, string>
  ) {
    const result: T[] = [];
    let isDone = false;
    const query = this.queryAllPages(paginationKey, resultKey, params);
    do {
      const { value, done } = await query.next();
      await new Promise((r) => setTimeout(r, 1000));
      if (value) {
        if (Array.isArray(value)) {
          result.push(...value);
        } else {
          if (resultKey === 'pages') {
            // @ts-ignore
            result.push(...Object.values(value));
          } else {
            result.push(value);
          }
        }
      }
      isDone = Boolean(done);
    } while (!isDone);
    return result;
  }

  public queryAllPages = async function* <T>(
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
      const response = await axios.get<PageSearch & CategorySearch>(
        this.baseUrl,
        {
          params: {
            ...params,
            [paginationKey]: next,
          },
          headers: {
            'User-Agent': 'Anyny0#4452 - Wiki tools',
          },
        }
      );

      next = response.data.continue?.[paginationKey];
      hasNext = Boolean(next);
      // @ts-ignore
      const values = response.data.query?.[resultKey] as T[];
      yield values;
    } while (hasNext);
    this.logger.log('Done!');
  };

  public async getRedirectsToPage(pageId: number): Promise<string[]> {
    const params = {
      action: 'query',
      format: 'json',
      prop: 'redirects',
      pageids: pageId,
      rdlimit: 500,
    };

    const response = await axios.get<{
      continue: unknown;
      query: {
        pages: {
          [pageId: string]: {
            pageid: number;
            redirects: { pageid: number; title: string }[];
          };
        };
      };
    }>(this.baseUrl, {
      params,
      headers: {
        'User-Agent': 'Anyny0#4452 - Wiki tools',
      },
    });

    return response?.data?.query?.pages?.[pageId]?.redirects?.map(
      (r) => r.title
    );
  }
}
