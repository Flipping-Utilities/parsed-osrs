import { Injectable, Logger } from '@nestjs/common';
import { ModuleDumper } from '../dumpers/module.dumper';
import { PageContentDumper } from '../dumpers/page-content.dumper';
import { PageListDumper } from '../dumpers/page-list.dumper';
import { ActivitiesExtractor } from '../extractors/activities.extractor';
import { ItemsExtractor } from '../extractors/items.extractor';
import { LocationsExtractor } from '../extractors/locations.extractor';
import { MonstersExtractor } from '../extractors/monsters.extractor';
import { MusicExtractor } from '../extractors/music.extractor';
import { NpcsExtractor } from '../extractors/npcs.extractor';
import { NewsExtractor } from '../extractors/news.extractor';
import { PrayersExtractor } from '../extractors/prayers.extractor';
import { QuestsExtractor } from '../extractors/quests.extractor';
import { RecipesExtractor } from '../extractors/recipes.extractor';
import { SceneryExtractor } from '../extractors/scenery.extractor';
import { SetsExtractor } from '../extractors/sets.extractor';
import { ShopsExtractor } from '../extractors/shops.extractor';
import { SpellsExtractor } from '../extractors/spells.extractor';
import { SpawnExtractor } from '../extractors/spawn.extractor';
import { TemplateExtractor } from '../extractors/template.extractor';

@Injectable()
export class DevService {
  private logger = new Logger(DevService.name);
  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
    private readonly moduleDumper: ModuleDumper,
    private readonly itemsExtractor: ItemsExtractor,
    private readonly setsExtractor: SetsExtractor,
    private readonly recipesExtractor: RecipesExtractor,
    private readonly shopsExtractor: ShopsExtractor,
    private readonly monstersExtractor: MonstersExtractor,
    private readonly spawnExtractor: SpawnExtractor,
    private readonly templateExtractor: TemplateExtractor,
    private readonly prayersExtractor: PrayersExtractor,
    private readonly spellsExtractor: SpellsExtractor,
    private readonly locationsExtractor: LocationsExtractor,
    private readonly npcsExtractor: NpcsExtractor,
    private readonly newsExtractor: NewsExtractor,
    private readonly sceneryExtractor: SceneryExtractor,
    private readonly questsExtractor: QuestsExtractor,
    private readonly activitiesExtractor: ActivitiesExtractor,
    private readonly musicExtractor: MusicExtractor
  ) {
    this.testTheThing();
  }

  async testTheThing() {
    this.dumpEverything();
    // await this.extractWikiContent();
  }

  async dumpEverything() {
    await this.dumpWikiContent();

    await this.extractWikiContent();
  }

  async dumpWikiContent() {
    await this.pageListDumper.dumpAllItemPageList();
    await this.pageListDumper.dumpGEItemPageList();
    await this.pageListDumper.dumpItemSetsPageList();
    await this.pageListDumper.dumpMonstersPageList();
    await this.pageListDumper.dumpShopPageList();
    await this.pageListDumper.dumpPrayersPageList();
    await this.pageListDumper.dumpSpellsPageList();
    await this.pageListDumper.dumpRecipePageList();
    await this.pageListDumper.dumpLocationPageList();
    await this.pageListDumper.dumpNpcPageList();
    await this.pageListDumper.dumpSceneryPageList();
    await this.pageListDumper.dumpQuestPageList();
    await this.pageListDumper.dumpActivityPageList();
    await this.pageListDumper.dumpItemSpawnPageList();
    await this.pageListDumper.dumpNewsPageList();
    await this.pageListDumper.dumpMusicPageList();
    // await this.moduleDumper.dumpAllModules();
    // await this.pageContentDumper.dumpPagesWithMissingContent();
    await this.pageListDumper.dumpRedirectList();
  }

  async extractWikiContent() {
    await this.itemsExtractor.extractAllItems();
    await this.setsExtractor.extractAllSets();
    await this.recipesExtractor.extractAllRecipes();
    await this.shopsExtractor.extractAllShops();
    await this.monstersExtractor.extractAllMonsters();
    await this.spawnExtractor.extractAllItemSpawns();
    await this.prayersExtractor.extractAllPrayers();
    await this.spellsExtractor.extractAllSpells();
    await this.locationsExtractor.extractAllLocations();
    await this.npcsExtractor.extractAllNpcs();
    await this.sceneryExtractor.extractAllScenery();
    await this.questsExtractor.extractAllQuests();
    await this.activitiesExtractor.extractAllActivities();
    await this.newsExtractor.extractAllNews();
    await this.musicExtractor.extractAllMusic();
    await this.templateExtractor.extractAllTemplates();
  }
}
