import { Injectable, Logger } from '@nestjs/common';
import { PageContentDumper } from '../dumpers/page-content.dumper';
import { PageListDumper } from '../dumpers/page-list.dumper';
import { ItemsExtractor } from '../extractors/items.extractor';
import { MonstersExtractor } from '../extractors/monsters.extractor';
import { RecipesExtractor } from '../extractors/recipes.extractor';
import { SetsExtractor } from '../extractors/sets.extractor';
import { ShopsExtractor } from '../extractors/shops.extractor';
import { SpawnExtractor } from '../extractors/spawn.extractor';
import { TemplateExtractor } from '../extractors/template.extractor';

@Injectable()
export class DevService {
  private logger = new Logger(DevService.name);
  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
    private readonly itemsExtractor: ItemsExtractor,
    private readonly setsExtractor: SetsExtractor,
    private readonly recipesExtractor: RecipesExtractor,
    private readonly shopsExtractor: ShopsExtractor,
    private readonly monstersExtractor: MonstersExtractor,
    private readonly spawnExtractor: SpawnExtractor,
    private readonly templateExtractor: TemplateExtractor
  ) {
    this.testTheThing();
  }

  async testTheThing() {
    // await this.recipesExtractor.extractAllRecipes();
    await this.extractWikiContent();
  }

  async dumpEverything() {
    await this.dumpWikiContent();
    await this.extractWikiContent();
  }

  async dumpWikiContent() {
    // Dumps the list of pages and some basic metadata
    await this.pageListDumper.dumpWikiPageList();
    // Uses the special:export feature to dump all pages and their raw content within an xml file
    await this.pageContentDumper.dumpAllWikiPagesFast();
    // Parses the xml file and extracts the content of each page
    await this.pageContentDumper.dumpAllWikiPages();
    // Dumps the additional content of the pages that were changed since the last run.
    await this.pageContentDumper.dumpAllPages();
    // Dumps the page list matching the various tags
    await this.pageListDumper.dumpAllItemPageList();
    await this.pageListDumper.dumpGEItemPageList();
    await this.pageListDumper.dumpItemSetsPageList();
    await this.pageListDumper.dumpMonstersPageList();
    await this.pageListDumper.dumpShopPageList();
    await this.pageListDumper.dumpItemSpawnPageList();
    await this.pageListDumper.dumpRedirectList();
  }

  async extractWikiContent() {
    await this.itemsExtractor.extractAllItems();
    await this.setsExtractor.extractAllSets();
    await this.recipesExtractor.extractAllRecipes();
    await this.shopsExtractor.extractAllShops();
    await this.monstersExtractor.extractAllMonsters();
    await this.spawnExtractor.extractAllItemSpawns();
    await this.templateExtractor.extractAllTemplates();
  }
}
