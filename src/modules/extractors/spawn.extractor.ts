import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_SPAWNS } from '../../constants/paths';
import { ItemSpawn } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import wtf from 'wtf_wikipedia';
import { PageTags } from 'src/constants/tags';

@Injectable()
export class SpawnExtractor {
  private logger: Logger = new Logger(SpawnExtractor.name);
  private cachedSpawns: ItemSpawn[] | null = null;
  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllItemSpawns() {
    this.logger.log('Start: extracting spawns');
    const itemsPageList = await this.pageListDumper.getPagesFromTag(
      PageTags.ITEM_SPAWN
    );

    const spawns: ItemSpawn[] = [];
    for await (const page of itemsPageList) {
      const spawnsFromPage = await this.extractSpawnsFromPageId(page.id);
      if (spawnsFromPage) {
        spawns.push(...spawnsFromPage.filter((v) => v));
      }
    }
    spawns.sort((a, b) => a.id - b.id);
    this.logger.log('End: extracting spawns');

    writeFileSync(ALL_SPAWNS, JSON.stringify(spawns));
  }

  public getAllSpawns(): ItemSpawn[] | null {
    if (!this.cachedSpawns) {
      const candidatePath = ALL_SPAWNS;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, 'utf8');
      let parsed: ItemSpawn[] | null = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.warn('all spawns has invalid content', e);
      }
      this.cachedSpawns = parsed;
    }

    return this.cachedSpawns;
  }

  private async extractSpawnsFromPageId(
    pageId: number
  ): Promise<ItemSpawn[] | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page) {
      return null;
    }
    const meta = wtf(page.text!);

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
          'Item spawn id not found: ' + page.title,
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
