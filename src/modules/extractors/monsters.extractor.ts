import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { load } from 'cheerio';
import { ALL_MONSTERS } from '../../constants/paths';
import { DropTable, Monster, MonsterDrop } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { ItemsExtractor } from './items.extractor';
import { PageTags } from '../../constants/tags';
import { parseWikitext } from '../../utils/wikitext-parser';
import { wikiNumber } from '../../utils/wiki-coercion';
import { expandDropTables } from '../../data/drop-tables';

const DROP_ROW_TEMPLATES = [
  'dropsline',
  'dropslineclue',
  'dropslineskill',
  'dropslinereward',
  'dropslineecumenical',
] as const;

function collectDropRowTemplates(
  parsed: ReturnType<typeof parseWikitext>
): Array<Record<string, unknown>> {
  const all: Array<Record<string, unknown>> = [];
  for (const name of DROP_ROW_TEMPLATES) {
    all.push(...parsed.getTemplates(name));
  }
  return all;
}

function collectDropTables(
  parsed: ReturnType<typeof parseWikitext>
): DropTable[] {
  const tables: DropTable[] = [];

  for (const rdt of parsed.getTemplates('raredroptable')) {
    tables.push({
      type: 'rare_drop_table',
      rarity: String(rdt.rdtRarity ?? ''),
      rolls: rdt.rolls ? String(rdt.rolls) : undefined,
      chaosTalisman: rdt.chaostalisman === 'yes',
      natureTalisman: rdt.naturetalisman === 'yes',
    });
    if (rdt.gdtRarity) {
      tables.push({
        type: 'gem_drop_table',
        rarity: String(rdt.gdtRarity),
        rolls: rdt.rolls ? String(rdt.rolls) : undefined,
        chaosTalisman: rdt.chaostalisman === 'yes',
        natureTalisman: rdt.naturetalisman === 'yes',
      });
    }
  }

  for (const gdt of parsed.getTemplates('gemdroptable')) {
    if (!tables.some((t) => t.type === 'gem_drop_table')) {
      tables.push({
        type: 'gem_drop_table',
        rarity: String(gdt.gdtRarity ?? ''),
        rolls: gdt.rolls ? String(gdt.rolls) : undefined,
        chaosTalisman: gdt.chaostalisman === 'yes',
        natureTalisman: gdt.naturetalisman === 'yes',
      });
    }
  }

  for (const herb of parsed.getTemplates('herbdroplines')) {
    tables.push({
      type: 'herb_drop_table',
      rarity: String(herb.rarity ?? ''),
      rolls: herb.rolls ? String(herb.rolls) : undefined,
    });
  }

  for (const seed of parsed.getTemplates('rareseeddroplines')) {
    tables.push({
      type: 'rare_seed_drop_table',
      rarity: String(seed.rarity ?? ''),
      rolls: seed.rolls ? String(seed.rolls) : undefined,
    });
  }

  for (const ws of parsed.getTemplates('wildernessslayerdroptable')) {
    tables.push({
      type: 'wilderness_slayer_table',
      combat: String(ws.combat ?? ws['1'] ?? ''),
      hitpoints: String(ws.hitpoints ?? ws['2'] ?? ''),
      boss: ws.boss === 'yes',
      superior: ws.superior === 'yes',
    });
  }

  for (const wsc of parsed.getTemplates('wildernessslayercavedroptable')) {
    tables.push({
      type: 'wilderness_slayer_cave_table',
      rarity: String(wsc['1'] ?? wsc.rarity ?? ''),
    });
  }

  for (const cat of parsed.getTemplates('catacombsdroptable')) {
    tables.push({
      type: 'catacombs_table',
      hitpoints: String(cat.hitpoints ?? cat['1'] ?? ''),
      superior: cat.superior === 'yes',
    });
  }

  for (const sup of parsed.getTemplates('superiordroptable')) {
    tables.push({
      type: 'superior_table',
      rarity: String(sup['1'] ?? ''),
    });
  }

  for (const bn of parsed.getTemplates('birdnestdroptable')) {
    tables.push({
      type: 'bird_nest_table',
      rarity: String(bn['1'] ?? bn.rarity ?? ''),
      rolls: bn.rolls ? String(bn.rolls) : undefined,
    });
  }

  for (const fossil of parsed.getTemplates('fossildroplines')) {
    tables.push({
      type: 'fossil_table',
      rarity: String(fossil.access ?? fossil['1'] ?? ''),
    });
  }

  return tables;
}

export function parseMonsterFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[],
  itemLookup: (name: string) => { id: number } | null
): Monster | null {
  const parsed = parseWikitext(pageText);
  const monsterData = parsed.getInfobox('monster');
  if (!monsterData) return null;

  const monsterId = wikiNumber(monsterData.id) || wikiNumber(monsterData.id1);
  if (!monsterId) return null;

  const examine = monsterData.examine ?? '';
  const dropTemplates = collectDropRowTemplates(parsed);

  const drops: MonsterDrop[] = dropTemplates
    .map((t) => {
      const name = String(t.name ?? '');
      const itemId = itemLookup(name)?.id ?? null;
      return {
        name,
        itemId,
        quantity: String(t.quantity ?? ''),
        rarity: String(t.rarity ?? ''),
      };
    })
    .filter((d) => d.name);

  const dropTables = collectDropTables(parsed);

  const herbTemplate = parsed.getTemplates('herbdroplines')[0];
  const herbQuantity = herbTemplate?.quantity ? String(herbTemplate.quantity) : undefined;
  const expandedDrops = expandDropTables(dropTables, herbQuantity);

  const subTableDrops: MonsterDrop[] = expandedDrops.map((d) => ({
    name: d.name,
    itemId: itemLookup(d.name)?.id ?? null,
    quantity: String(d.quantity),
    rarity: d.rarity,
  }));

  const expandedNames = new Set(subTableDrops.map((d) => d.name));
  const uniqueDrops = drops.filter((d) => !expandedNames.has(d.name));

  return {
    id: monsterId,
    name: pageTitle,
    aliases: pageAliases,
    drops: [...uniqueDrops, ...subTableDrops],
    dropTables,
    examine,
  };
}

export function parseMonsterFromHtml(
  html: string,
  pageTitle: string,
  pageAliases: string[],
  itemLookup: (name: string) => { id: number } | null
): Monster | null {
  const dom = load(html);

  const allDrops: MonsterDrop[] = [];
  Array.from(dom('.item-drops')).forEach((table) => {
    const rows = load(table)('tr').filter((i, e) => {
      return dom(e).children()[0]?.tagName === 'td';
    });

    const sectionDrops: MonsterDrop[] = Array.from(rows)
      .map((row) => {
        const element = dom(row);
        const [_, nameElement, qtyElement, rarityElement] = element.children();
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

        const itemId = itemLookup(name)?.id || null;

        return { name: name, quantity: quantity, rarity: rarity, itemId };
      })
      .filter((r) => r.name) as MonsterDrop[];
    allDrops.push(...sectionDrops);
  });

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
    return null;
  }

  return {
    id: realId,
    name: pageTitle,
    aliases: pageAliases,
    drops: allDrops,
    dropTables: [],
    examine: '',
  };
}

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

    const lookup = (name: string) => this.itemExtractor.getItemByName(name);

    if (page.text) {
      const monster = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases || [],
        lookup
      );
      if (!monster) {
        this.logger.warn('no id for monster', page.title, page.id);
      }
      return monster;
    }

    if (page.html) {
      const monster = parseMonsterFromHtml(
        page.html,
        page.title,
        page.aliases || [],
        lookup
      );
      if (monster) {
        this.logger.debug('parsed monster from HTML fallback', page.title);
      }
      return monster;
    }

    this.logger.warn('No text or html for monster', page.title, page.id);
    return null;
  }
}
