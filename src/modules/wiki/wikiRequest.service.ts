import { Injectable, Logger } from '@nestjs/common';
import axios from 'axios';

export interface ApiQueryBase {
  batchcomplete: string;
  continue: {
    continue: string;
  };
  limits: {};
  query: {};
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
  content: string;
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
  ): Promise<T> {
    const response = await axios
      .get<T>(this.baseUrl, {
        params,
        headers: {
          'User-Agent': 'Anyny0#4452 - Wiki tools',
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
    paginationKey: 'cmcontinue' | 'apcontinue' | 'eicontinue',
    resultKey: 'categorymembers' | 'allpages' | 'embeddedin',
    params: { action: string } & Record<string, string>
  ) {
    const result: T[] = [];
    let isDone = false;
    const query = this.queryAllPages(paginationKey, resultKey, params);
    do {
      const { value, done } = await query.next();
      if (value) {
        result.push(...value);
      }
      isDone = Boolean(done);
    } while (!isDone);
    return result;
  }

  public queryAllPages = async function* <T>(
    paginationKey: 'cmcontinue' | 'apcontinue' | 'eicontinue',
    resultKey: 'categorymembers' | 'allpages' | 'embeddedin',
    params: { action: string } & Record<string, string>
  ): AsyncGenerator<T[]> {
    let next: string | undefined = undefined;
    let hasNext = true;
    let i = 0;
    do {
      if (i++ % 10 === 0) {
        this.logger.log(`Querying pages: ${i}`);
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
      const values = response.data.query[resultKey] as T[];
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
