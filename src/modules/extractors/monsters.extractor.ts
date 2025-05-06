import { Injectable, Logger } from '@nestjs/common';
import { load } from 'cheerio';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_MONSTERS } from '../../constants/paths';
import { Monster, MonsterDrop } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { ItemsExtractor } from './items.extractor';
import { PageTags } from 'src/constants/tags';
import wtf from 'wtf_wikipedia';

@Injectable()
export class MonstersExtractor {
  private logger: Logger = new Logger(MonstersExtractor.name);

  private cachedMonsters: Monster[] | null = null;

  constructor(
    private itemExtractor: ItemsExtractor,
    private pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllMonsters() {
    this.logger.log('Start: Extracting monsters');

    const monstersPage = await this.pageListDumper.getPagesFromTag(
      PageTags.MONSTER
    );
    const length = monstersPage.length;
    const monsters: Monster[] = [];
    let i = 0;
    for await (const page of monstersPage) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Monsters: ${i}/${length}`);
      }
      const monster = await this.extractMonsterFromPageId(page.id);
      if (monster) {
        monsters.push(monster);
      }
    }

    if (monsters.length) {
      writeFileSync(ALL_MONSTERS, JSON.stringify(monsters));
    }

    this.logger.log('Done: Extracting monsters');
    return monsters;
  }

  public getAllMonsters(): Monster[] | null {
    if (!this.cachedMonsters) {
      const candidatePath = ALL_MONSTERS;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, 'utf8');
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.log('all monsters has invalid content', e);
      }
      this.cachedMonsters = parsed;
    }

    return this.cachedMonsters;
  }

  private async extractMonsterFromPageId(
    pageId: number
  ): Promise<Monster | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page) {
      this.logger.warn('Could not fetch page content from id', pageId);
      return null;
    }

    const html = page.html;
    if (html === null) {
      return null;
    }
    const dom = load(html);

    const allDrops: MonsterDrop[] = [];
    Array.from(dom('.item-drops')).forEach((table) => {
      const rows = load(table)('tr').filter((i, e) => {
        return dom(e).children()[0]?.tagName === 'td';
      });

      const sectionDrops: MonsterDrop[] = Array.from(rows)
        .map((row) => {
          const element = dom(row);
          const [_, nameElement, qtyElement, rarityElement] =
            element.children();
          const name = dom(nameElement.childNodes[0] || nameElement)
            .text()
            ?.split('[')[0]
            .replace(/,/g, '')
            .trim();
          const quantity = dom(qtyElement.childNodes[0] || qtyElement)
            .text()
            ?.split('[')[0]
            .replace(/,/g, '')
            .trim();
          const rarity = dom(rarityElement.childNodes[0] || rarityElement)
            .text()
            ?.split('[')[0]
            .replace(/,/g, '')
            .trim();

          const itemId = this.itemExtractor.getItemByName(name)?.id || null;

          return { name: name, quantity: quantity, rarity: rarity, itemId };
        })
        .filter((r) => r.name) as MonsterDrop[];
      allDrops.push(...sectionDrops);
    });

    // If there are multiple ids: 12, 34
    // The data-attr-param is present
    // Otherwise, it is not there
    const candidateIdElement = dom(
      dom('.advanced-data')
        .filter((i, e) => {
          return dom(e).children().first().text().includes('Monster ID');
        })
        .first()
    )?.children('td');

    const candidateId = dom(candidateIdElement)?.text()?.split(',')[0];

    const realId = Number(candidateId);
    if (!candidateId || isNaN(realId)) {
      this.logger.warn('no id for monster', page.title, page.id);
      return null;
    }
    let examine = '';
    const text = page.text;

    if (text) {
      const potentialExamine: string = wtf(text)
        .infobox()
        // @ts-ignore
        ?.data?.examine?.text();
      if (potentialExamine) {
        examine = potentialExamine;
      }
    }

    const monster: Monster = {
      id: realId,
      name: page.title,
      aliases: page.aliases || [],
      drops: allDrops,
      examine,
    };

    return monster;
  }
}
