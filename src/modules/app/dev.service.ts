import { Injectable, Logger } from '@nestjs/common';
import { PageContentDumper } from '../dumpers/page-content.dumper';
import { PageListDumper } from '../dumpers/page-list.dumper';
import { ItemsExtractor } from '../extractors/items.extractor';
import { RecipesExtractor } from '../extractors/recipes.extractor';
import { SetsExtractor } from '../extractors/sets.extractor';

@Injectable()
export class DevService {
  private logger = new Logger(DevService.name);
  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
    private readonly itemsExtractor: ItemsExtractor,
    private readonly setsExtractor: SetsExtractor,
    private readonly recipesExtractor: RecipesExtractor
  ) {
    // this.dumpEverything();
    this.testTheThing();
  }

  async testTheThing() {
    await this.recipesExtractor.extractAllRecipes();
  }

  async dumpEverything() {
    await this.dumpWikiContent();
    await this.extractWikiContent();
  }

  async dumpWikiContent() {
    await this.pageListDumper.dumpWikiPageList();
    await this.pageContentDumper.dumpAllWikiPages();
    await this.pageListDumper.dumpAllItemPageList();
    await this.pageListDumper.dumpGEItemPageList();
    await this.pageListDumper.dumpItemSetsPageList();
    await this.pageListDumper.dumpMonstersPageList();
    await this.pageListDumper.dumpShopPageList();
    await this.pageListDumper.dumpRedirectList();
  }

  async extractWikiContent() {
    await this.itemsExtractor.extractAllItems();
    await this.setsExtractor.extractAllSets();
    await this.recipesExtractor.extractAllRecipes();
  }
}
