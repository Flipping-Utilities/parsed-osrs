import { Injectable, Logger, type OnModuleInit } from "@nestjs/common";
import { ModuleDumper } from "../dumpers/module.dumper";
import { PageContentDumper } from "../dumpers/page-content.dumper";
import { PageListDumper } from "../dumpers/page-list.dumper";
import { DatabaseService } from "../database/database.service";
import { ActivitiesExtractor } from "../extractors/activities.extractor";
import { ItemsExtractor } from "../extractors/items.extractor";
import { LocationsExtractor } from "../extractors/locations.extractor";
import { MonstersExtractor } from "../extractors/monsters.extractor";
import { MusicExtractor } from "../extractors/music.extractor";
import { NpcsExtractor } from "../extractors/npcs.extractor";
import { NewsExtractor } from "../extractors/news.extractor";
import { PrayersExtractor } from "../extractors/prayers.extractor";
import { QuestsExtractor } from "../extractors/quests.extractor";
import { RecipesExtractor } from "../extractors/recipes.extractor";
import { SceneryExtractor } from "../extractors/scenery.extractor";
import { SetsExtractor } from "../extractors/sets.extractor";
import { ShopsExtractor } from "../extractors/shops.extractor";
import { SpellsExtractor } from "../extractors/spells.extractor";
import { SpawnExtractor } from "../extractors/spawn.extractor";
import { TemplateExtractor } from "../extractors/template.extractor";

/** KV key recording the ISO timestamp when the last wiki dump *started*. */
const LAST_DUMP_KEY = "last_wiki_dump_at";

@Injectable()
export class DevService implements OnModuleInit {
  private logger = new Logger(DevService.name);
  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
    private readonly moduleDumper: ModuleDumper,
    private readonly databaseService: DatabaseService,
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
    private readonly musicExtractor: MusicExtractor,
  ) {}

  /**
   * NestJS guarantees this fires AFTER all of this service's dependencies
   * have finished their own `onModuleInit` — including
   * {@link DatabaseService.onModuleInit}, which creates the schema. Doing the
   * work here (rather than in the constructor) is what guarantees the `kv`
   * table exists by the time `shouldSkipDump` queries it.
   */
  async onModuleInit(): Promise<void> {
    await this.testTheThing();
  }

  async testTheThing() {
    await this.dumpEverything();
    // await this.pageListDumper.dumpQuestPageList();
    // await this.pageListDumper.dumpQuestGuidePageList();
    // await this.questsExtractor.extractAllQuests();
  }

  async dumpEverything() {
    if (await this.shouldSkipDump()) {
      this.logger.log(
        "Skipping wiki dump — last run is more recent than MIN_REFRESH_HOURS. " +
          "Re-extracting only.",
      );
    } else {
      // Stamp the dump start BEFORE running it. If the dump crashes, the
      // next run within the window will still skip — which is the safer
      // behaviour than retrying every cron tick. To force a re-dump, clear
      // the `last_wiki_dump_at` row in the `kv` table.
      await this.databaseService.setKv(LAST_DUMP_KEY, new Date().toISOString());
      await this.dumpWikiContent();
    }
    await this.extractWikiContent();
  }

  /**
   * Returns `true` when the previous wiki dump started less than
   * `MIN_REFRESH_HOURS` ago. Extraction always runs — it just re-parses
   * whatever is already in the DB.
   *
   * `MIN_REFRESH_HOURS=0` (the default) disables the gate so the workflow is
   * unchanged from before.
   */
  private async shouldSkipDump(): Promise<boolean> {
    const minHours = Number(process.env.MIN_REFRESH_HOURS ?? 0);
    if (!minHours || minHours <= 0) return false;

    const last = await this.databaseService.getKv(LAST_DUMP_KEY);
    if (!last) return false;

    const ageMs = Date.now() - new Date(last).getTime();
    const minMs = minHours * 60 * 60 * 1000;
    return ageMs < minMs;
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
    await this.pageListDumper.dumpQuestGuidePageList();
    await this.pageListDumper.dumpActivityPageList();
    await this.pageListDumper.dumpItemSpawnPageList();
    await this.pageListDumper.dumpNewsPageList();
    await this.pageListDumper.dumpMusicPageList();
    await this.moduleDumper.dumpAllModules();
    await this.pageContentDumper.dumpPagesWithMissingContent();
    // Aliases change slowly — fetching them is ~30 min for OSRS (~80k pages
    // at 50 titles per request, 1s throttle). Gate on SKIP_REDIRECT_REFRESH
    // so daily cron can opt out and only the weekly run pays the cost.
    if (process.env.SKIP_REDIRECT_REFRESH !== 'true') {
      await this.pageListDumper.dumpRedirectList();
    } else {
      this.logger.log('Skipping redirect refresh (SKIP_REDIRECT_REFRESH=true)');
    }
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
