import { Injectable, Logger, type OnModuleInit } from "@nestjs/common";
import { Rs3ModuleDumper } from "../dumpers/rs3-module.dumper";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";
import { Rs3DatabaseService } from "../database/rs3-database.service";
import { Rs3ActivitiesExtractor } from "../extractors/rs3-activities.extractor";
import { Rs3ItemsExtractor } from "../extractors/rs3-items.extractor";
import { Rs3LocationsExtractor } from "../extractors/rs3-locations.extractor";
import { Rs3MonstersExtractor } from "../extractors/rs3-monsters.extractor";
import { Rs3MusicExtractor } from "../extractors/rs3-music.extractor";
import { Rs3NewsExtractor } from "../extractors/rs3-news.extractor";
import { Rs3NpcsExtractor } from "../extractors/rs3-npcs.extractor";
import { Rs3PrayersExtractor } from "../extractors/rs3-prayers.extractor";
import { Rs3QuestsExtractor } from "../extractors/rs3-quests.extractor";
import { Rs3RecipesExtractor } from "../extractors/rs3-recipes.extractor";
import { Rs3SceneryExtractor } from "../extractors/rs3-scenery.extractor";
import { Rs3SetsExtractor } from "../extractors/rs3-sets.extractor";
import { Rs3ShopsExtractor } from "../extractors/rs3-shops.extractor";
import { Rs3SpellsExtractor } from "../extractors/rs3-spells.extractor";
import { Rs3SpawnExtractor } from "../extractors/rs3-spawn.extractor";
import { Rs3TemplateExtractor } from "../extractors/rs3-template.extractor";

/** KV key recording the ISO timestamp when the last RS3 wiki dump started. */
const LAST_DUMP_KEY = "last_wiki_dump_at";

/**
 * RS3 counterpart of {@link DevService}.
 *
 * Runs the same two-phase dump → extract pipeline as the OSRS dev service,
 * but against the RS3 wiki, the RS3 SQLite DB, and the `data/rs3/...` output
 * tree. Activated from {@link AppModule} when `GAME=rs3`.
 *
 * Honours `MIN_REFRESH_HOURS` exactly like the OSRS service: when the last
 * dump started within that window, only the extract phase runs.
 */
@Injectable()
export class Rs3DevService implements OnModuleInit {
  private logger = new Logger(Rs3DevService.name);
  constructor(
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
    private readonly moduleDumper: Rs3ModuleDumper,
    private readonly databaseService: Rs3DatabaseService,
    private readonly itemsExtractor: Rs3ItemsExtractor,
    private readonly setsExtractor: Rs3SetsExtractor,
    private readonly recipesExtractor: Rs3RecipesExtractor,
    private readonly shopsExtractor: Rs3ShopsExtractor,
    private readonly monstersExtractor: Rs3MonstersExtractor,
    private readonly spawnExtractor: Rs3SpawnExtractor,
    private readonly templateExtractor: Rs3TemplateExtractor,
    private readonly prayersExtractor: Rs3PrayersExtractor,
    private readonly spellsExtractor: Rs3SpellsExtractor,
    private readonly locationsExtractor: Rs3LocationsExtractor,
    private readonly npcsExtractor: Rs3NpcsExtractor,
    private readonly newsExtractor: Rs3NewsExtractor,
    private readonly sceneryExtractor: Rs3SceneryExtractor,
    private readonly questsExtractor: Rs3QuestsExtractor,
    private readonly activitiesExtractor: Rs3ActivitiesExtractor,
    private readonly musicExtractor: Rs3MusicExtractor,
  ) {}

  /**
   * Fires AFTER {@link Rs3DatabaseService.onModuleInit} (which creates the
   * schema) thanks to NestJS's dependency-ordered lifecycle.
   */
  async onModuleInit(): Promise<void> {
    await this.testTheThing();
  }

  async testTheThing() {
    await this.dumpEverything();
  }

  async dumpEverything() {
    if (await this.shouldSkipDump()) {
      this.logger.log(
        "Skipping RS3 wiki dump — last run is more recent than MIN_REFRESH_HOURS. " +
          "Re-extracting only.",
      );
    } else {
      await this.databaseService.setKv(LAST_DUMP_KEY, new Date().toISOString());
      await this.dumpWikiContent();
    }
    await this.extractWikiContent();
  }

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
    // Aliases change slowly — fetching them is ~30–45 min for RS3. Gate on
    // SKIP_REDIRECT_REFRESH so daily cron can opt out and only the weekly
    // run pays the cost. Mirrors the OSRS DevService.
    if (process.env.SKIP_REDIRECT_REFRESH !== "true") {
      await this.pageListDumper.dumpRedirectList();
    } else {
      this.logger.log("Skipping redirect refresh (SKIP_REDIRECT_REFRESH=true)");
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
