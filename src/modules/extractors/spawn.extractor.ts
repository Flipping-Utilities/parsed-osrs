import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_SPAWNS } from '../../constants/paths';
import { ItemSpawn } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';

@Injectable()
export class SpawnExtractor {
  private logger: Logger = new Logger(SpawnExtractor.name);
  private cachedSpawns: ItemSpawn[];
  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllItemSpawns() {
    const itemsPageList = this.pageListDumper.getAllItems();

    const spawns = itemsPageList
      .map((item) => this.extractSpawnsFromPageId(item.pageid))
      .filter((v) => v)
      .reduce((acc, spawns) => {
        acc.push(...spawns);
        return acc;
      }, [])
      .filter((v) => v);

    this.logger.error(spawns.length);

    writeFileSync(ALL_SPAWNS, JSON.stringify(spawns, null, 2));
  }

  public getAllItems(): ItemSpawn[] | null {
    if (!this.cachedSpawns) {
      const candidatePath = ALL_SPAWNS;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, 'utf8');
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.warn('all spawns has invalid content', e);
      }
      this.cachedSpawns = parsed;
    }

    return this.cachedSpawns;
  }

  private extractSpawnsFromPageId(pageId: number): ItemSpawn[] | null {
    const page = this.pageContentDumper.getPageFromId(pageId);
    if (!page) {
      return null;
    }

    const spawnLineRegex = /\{\{ItemSpawnLine\|((?:.|\n)*?)\}\}\n/gm;

    const spawns = Array.from(page.rawContent.matchAll(spawnLineRegex));

    if (spawns.length === 0) {
      return null;
    }

    // @ts-ignore
    return spawns.map((s) => s[1].replaceAll('\n', ''));

    return spawns.map((spawnLine) => {
      const [name, location, members, ...positions] = spawnLine[1]
        // {{ItemSpawnLine|name=Astronomy book|location=[[Observatory]] reception west of [[Tree Gnome Village (location)|Tree Gnome Village]]|members=Yes|2438,3187}}
        .split(/\|(?![^\[]*\])/g)
        .map((v, i) => v.split('=')[v.split('=').length - 1]);

      const spawn: ItemSpawn = {
        itemName: name,
        location,
        members: members.toLowerCase() === 'yes',
        // @ts-ignore
        positions: positions.map((v) =>
          v.split(',').map((n) => Number(n.split(':')[n.split(':').length - 1]))
        ),
      };
      console.log(spawn, positions);
      return spawn;
    });
  }
}
