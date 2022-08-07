import { Injectable, Logger } from '@nestjs/common';
import { load } from 'cheerio';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_MONSTERS } from '../../constants/paths';
import { Monster, MonsterDrop } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { ItemsExtractor } from './items.extractor';

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
    this.logger.log('Starting to extract monsters');

    const monstersPage = this.pageListDumper.getMonsters();
    const length = monstersPage.length;
    const monsters = monstersPage
      .map((page, i) => {
        if (i % 100 === 0) {
          this.logger.debug(`Monsters: ${i}/${length}`);
        }
        return this.extractMonsterFromPageId(page.pageid);
      })
      .filter((v) => v);

    if (monsters.length) {
      writeFileSync(ALL_MONSTERS, JSON.stringify(monsters, null, 2));
    }

    this.logger.log('Finished extracting monsters');

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

  private extractMonsterFromPageId(pageId: number): Monster | null {
    const page = this.pageContentDumper.getPageFromId(pageId);

    const html = page.content;
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
            .replace(/,/g, '');
          const quantity = dom(qtyElement.childNodes[0] || qtyElement)
            .text()
            ?.split('[')[0]
            .replace(/,/g, '');
          const rarity = dom(rarityElement.childNodes[0] || rarityElement)
            .text()
            ?.split('[')[0]
            .replace(/,/g, '');

          const itemId = this.itemExtractor.getItemByName(name)?.id || null;

          return { name: name, quantity: quantity, rarity: rarity, itemId };
        })
        .filter((r) => r.name) as MonsterDrop[];
      allDrops.push(...sectionDrops);
    });

    const monster: Monster = {
      name: page.title,
      aliases: page.redirects || [],
      drops: allDrops,
      examine:
        page.properties.find((p) => p.name === 'description')?.value || '',
    };

    return monster;
  }
}
