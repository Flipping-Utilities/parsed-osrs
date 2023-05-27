import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_SPAWNS } from '../../constants/paths';
import { ItemSpawn } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import * as wtf from 'wtf_wikipedia';

@Injectable()
export class SpawnExtractor {
  private logger: Logger = new Logger(SpawnExtractor.name);
  private cachedSpawns: ItemSpawn[];
  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllItemSpawns() {
    const itemsPageList = this.pageListDumper.getItemSpawns();

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
    const meta = wtf(page.rawContent);

    const itemInfobox = meta
      .infoboxes()
      .find((infobox) => infobox.type() === 'item');
    if (!itemInfobox) {
      this.logger.warn('No item infobox for page: ' + pageId);
      return null;
    }
    const itemInfoboxData: any = itemInfobox.data;

    const itemIds: Record<string, number> = {};

    const getItemId = (name: string) => {
      const id = itemIds[name.toLowerCase()];
      if (!id) {
        this.logger.warn(
          'Item spawn id not found: ' + page.pagename,
          name,
          itemIds
        );
        return Object.values(itemIds)[0];
      }
      return id;
    };

    if (itemInfoboxData.id) {
      itemIds[itemInfoboxData.name.text().toLowerCase()] = parseInt(
        itemInfoboxData.id.text()
      );
    } else {
      // Item variations
      Object.keys(itemInfoboxData)
        .filter((key) => key.startsWith('id'))
        .forEach((idKey) => {
          const postfix = idKey.substring('id'.length);
          let nameKey = 'name' + postfix;
          if (!itemInfoboxData[nameKey]) {
            nameKey = 'name';
          }
          itemIds[itemInfoboxData[nameKey].text().toLowerCase()] = parseInt(
            itemInfoboxData[idKey].text()
          );
        });
    }

    const itemSpawnLines: any[] = meta
      .templates()
      .filter(
        (template: any) =>
          template.data.template === 'itemspawnline' && template.data.list
      );

    return itemSpawnLines.flatMap((itemSpawnLine): ItemSpawn[] => {
      const plane = parseInt(itemSpawnLine.data.plane || 0);
      return itemSpawnLine.data.list.map((spawnLine: string): ItemSpawn => {
        const name: string = itemSpawnLine.data.name;
        const id = getItemId(name);
        const split = spawnLine.split(',');
        const quantity = split.length === 3 ? parseInt(split[2].slice(4)) : 1;
        return {
          id,
          name,
          quantity: quantity,
          x: parseInt(split[0]),
          y: parseInt(split[1]),
          plane,
          location: itemSpawnLine.data.location,
          members: itemSpawnLine.data.members !== 'No',
        };
      });
    });
  }
}
