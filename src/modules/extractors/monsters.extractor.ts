import { Injectable, Logger } from '@nestjs/common';
import { load } from 'cheerio';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_MONSTERS } from '../../constants/paths';
import { Monster, MonsterCombatStats, MonsterDrop } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { ItemsExtractor } from './items.extractor';
// @ts-ignore
import * as parseInfo from 'infobox-parser';
import { WikiPageWithContent } from '../wiki/wikiRequest.service';

interface WikiMonster {
  version: string;
  name: string;
  image: string;
  release: string;
  update: string;
  removal: string;
  removalupdate: string;
  members: 'Yes' | 'No' | boolean;
  combat: string;
  size: string;
  examine: string;
  xpbonus: string;
  maxHit: string;
  aggressive: 'Yes' | 'No' | boolean;
  poisonous: 'Yes' | 'No' | boolean;
  attackStyle: string;
  attackSpeed: string;
  slayxp: string;
  cat: string;
  assignedby: string;
  hitpoints: string;
  att: string;
  str: string;
  def: string;
  mage: string;
  range: string;
  attbns: string;
  strbns: string;
  amagic: string;
  mbns: string;
  arange: string;
  rngbns: string;
  dstab: string;
  dslash: string;
  dcrush: string;
  dmagic: string;
  drange: string;
  immunepoison: 'Not immune' | 'Immune';
  immunevenom: 'Not immune' | 'Immune';
  immunecannon: 'Yes' | 'No' | boolean;
  immunethrall: 'Yes' | 'No' | boolean;
  respawn: string;
  id: string;
  dropversion: string;
}
const WikiToMonsterKeys: Partial<
  Record<Partial<keyof WikiMonster>, Partial<keyof Monster>>
> = {
  id: 'ids',
  version: 'version',
  name: 'name',
  image: 'image',
  release: 'release',
  update: 'update',
  removal: 'removal',
  removalupdate: 'removalUpdate',
  members: 'members',
  combat: 'level',
  size: 'size',
  examine: 'examine',
  xpbonus: 'xpBonus',
  maxHit: 'maxHit',
  aggressive: 'aggressive',
  poisonous: 'poisonous',
  attackStyle: 'attackStyle',
  attackSpeed: 'attackSpeed',
  slayxp: 'slayXp',
  cat: 'category',
  assignedby: 'assignedBy',
  hitpoints: 'hitpoints',
  respawn: 'respawnTime',
  dropversion: 'dropTable',
};
const WikiToMonsterCombatStatsKeys: Partial<
  Record<Partial<keyof WikiMonster>, Partial<keyof MonsterCombatStats>>
> = {
  att: 'attack',
  str: 'strength',
  def: 'defence',
  mage: 'magic',
  range: 'ranged',
  attbns: 'attackBonus',
  strbns: 'strengthBonus',
  amagic: 'attackMagic',
  mbns: 'magicBonus',
  arange: 'attackRanged',
  rngbns: 'rangedBonus',
  dstab: 'defenceStab',
  dslash: 'defenceSlash',
  dcrush: 'defenceCrush',
  dmagic: 'defenceMagic',
  drange: 'defenceRanged',
  immunepoison: 'immunePosion',
  immunevenom: 'immuneVenom',
  immunecannon: 'immuneCannon',
  immunethrall: 'immuneThrall',
};
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
      // .filter((i) => i.pageid === 11672)
      .map((page, i) => {
        if (i % 100 === 0) {
          this.logger.debug(`Monsters: ${i}/${length}`);
        }
        return this.extractMonstersFromPageId(page.pageid);
      })
      .flat()
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
  private extractInfoBoxFromPage(
    page: WikiPageWithContent
  ): WikiMonster | null {
    const infoBoxStart = page.rawContent.indexOf('{{Infobox Monster');
    const infoBoxString = page.rawContent.slice(
      infoBoxStart,
      page.rawContent.indexOf('}}', infoBoxStart) + 2
    );
    return parseInfo(infoBoxString).general;
  }
  private extractMonstersFromPageId(pageId: number): Monster[] | null {
    const page = this.pageContentDumper.getPageFromId(pageId);
    if (!page) {
      this.logger.warn('Could not fetch page content from id', pageId);
      return null;
    }
    const monsterInfoBox = this.extractInfoBoxFromPage(page);
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

    const idList = monsterInfoBox.id?.split(',').map((i) => Number(i)) || [0];
    const baseItem: Monster = {
      id: idList[0],
      ids: idList,

      version: monsterInfoBox.version,
      name: monsterInfoBox.name,
      image: monsterInfoBox.image,
      release: monsterInfoBox.release,
      update: monsterInfoBox.update,
      members: monsterInfoBox.members === 'Yes',
      level: Number(monsterInfoBox.combat),
      size: Number(monsterInfoBox.size),
      examine: monsterInfoBox.examine,
      xpBonus: Number(monsterInfoBox.xpbonus),
      maxHit: Number(monsterInfoBox['maxHit']),
      aggressive: monsterInfoBox.aggressive === 'Yes',
      poisonous: monsterInfoBox.poisonous === 'Yes',
      attackStyle: monsterInfoBox['attackStyle'],
      attackSpeed: Number(monsterInfoBox['attackSpeed']),
      slayXp: Number(monsterInfoBox.slayxp),
      category: monsterInfoBox.cat,
      hitpoints: Number(monsterInfoBox.hitpoints),
      assignedBy: monsterInfoBox.assignedby?.split(',') || [],
      combatStats: {
        attack: Number(monsterInfoBox.att),
        strength: Number(monsterInfoBox.str),
        defence: Number(monsterInfoBox.def),
        magic: Number(monsterInfoBox.mage),
        ranged: Number(monsterInfoBox.range),

        attackBonus: Number(monsterInfoBox.attbns),
        strengthBonus: Number(monsterInfoBox.strbns),
        attackMagic: Number(monsterInfoBox.amagic),
        magicBonus: Number(monsterInfoBox.mbns),

        attackRanged: Number(monsterInfoBox.arange),
        rangedBonus: Number(monsterInfoBox.rngbns),
        defenceStab: Number(monsterInfoBox.dstab),
        defenceSlash: Number(monsterInfoBox.dslash),
        defenceCrush: Number(monsterInfoBox.dcrush),
        defenceMagic: Number(monsterInfoBox.dmagic),
        defenceRanged: Number(monsterInfoBox.drange),

        immunePosion: monsterInfoBox.immunepoison === 'Immune',
        immuneVenom: monsterInfoBox.immunevenom === 'Immune',
        immuneCannon: monsterInfoBox.immunecannon === 'Yes',
        immuneThrall: monsterInfoBox.immunethrall === 'Yes',
      },
      respawnTime: Number(monsterInfoBox.respawn),
      dropTable: monsterInfoBox.dropversion,
      aliases: page.redirects || [],
    };

    const variants: Monster[] = [];
    Object.keys(monsterInfoBox).forEach((key) => {
      const candidateKey = key.match(/\d+$/);
      const endIndex = candidateKey ? Number(candidateKey[0]) : 0;
      const baseKey = key.replace(/\d+$/, '');
      if (key === baseKey || endIndex === 0) {
        return;
      }

      if (!variants[endIndex]) {
        variants[endIndex] = {
          ...baseItem,
          combatStats: { ...baseItem.combatStats },
        };
      }
      let value;
      let cbValue;
      switch (baseKey as keyof WikiMonster) {
        case 'id':
          // Because we're saving both the id and the list, we need to split the value
          value = (monsterInfoBox as any)[key]
            .split(',')
            .map((i: string) => Number(i));
          variants[endIndex]['id'] = value[0];
          break;
        case 'dropversion':
        case 'hitpoints':
        case 'cat':
        case 'release':
        case 'update':
        case 'version':
        case 'image':
        case 'name':
        case 'examine':
        case 'removal':
        case 'removalupdate':
          value = (monsterInfoBox as any)[key];
          break;
        case 'members':
          value =
            (monsterInfoBox as any)[key] === 'Yes' ||
            (monsterInfoBox as any)[key] === true;
          break;
        case 'slayxp':
        case 'xpbonus':
        case 'maxHit':
        case 'attackSpeed':
        case 'combat':
        case 'size':
        case 'hitpoints':

        case 'respawn':
          value = Number((monsterInfoBox as any)[key]);
          break;
        case 'assignedby':
          value = (monsterInfoBox as any)[key].split(',');
          break;

        // Combat Stats
        case 'att':
        case 'str':
        case 'def':
        case 'mage':
        case 'range':
        case 'attbns':
        case 'strbns':
        case 'amagic':
        case 'mbns':
        case 'arange':
        case 'rngbns':
        case 'dstab':
        case 'dslash':
        case 'dcrush':
        case 'dmagic':
        case 'drange':
          cbValue = Number((monsterInfoBox as any)[key]);
          break;
        case 'immunepoison':
        case 'immunevenom':
        case 'immunecannon':
        case 'immunethrall':
          const kv = (monsterInfoBox as any)[key];
          cbValue = ['Yes', 'Immune', true].includes(kv);
          break;
        default:
          break;
      }
      if (value) {
        // @ts-ignore
        variants[endIndex][WikiToMonsterKeys[baseKey]] = value;
      }
      if (cbValue) {
        // @ts-ignore
        variants[endIndex].combatStats[WikiToMonsterCombatStatsKeys[baseKey]] =
          cbValue;
      }
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
      console.debug(candidateId);
      this.logger.warn('no id for monster', page.title, page.pageid);
      return [null];
    }

    // const monster: Monster = {
    //   id: realId,
    //   name: page.title,
    //   aliases: page.redirects || [],
    //   //drops: allDrops,
    //   examine:
    //     page.properties.find((p) => p.name === 'description')?.value || '',
    // };

    return variants;
  }
}
