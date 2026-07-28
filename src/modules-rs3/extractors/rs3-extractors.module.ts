import { Module } from "@nestjs/common";
import { Rs3DatabaseModule } from "../database/rs3-database.module";
import { Rs3DumpersModule } from "../dumpers/rs3-dumpers.module";
import { Rs3ActivitiesExtractor } from "./rs3-activities.extractor";
import { Rs3ItemsExtractor } from "./rs3-items.extractor";
import { Rs3LocationsExtractor } from "./rs3-locations.extractor";
import { Rs3MonstersExtractor } from "./rs3-monsters.extractor";
import { Rs3MusicExtractor } from "./rs3-music.extractor";
import { Rs3NewsExtractor } from "./rs3-news.extractor";
import { Rs3NpcsExtractor } from "./rs3-npcs.extractor";
import { Rs3PrayersExtractor } from "./rs3-prayers.extractor";
import { Rs3QuestsExtractor } from "./rs3-quests.extractor";
import { Rs3RecipesExtractor } from "./rs3-recipes.extractor";
import { Rs3SceneryExtractor } from "./rs3-scenery.extractor";
import { Rs3SetsExtractor } from "./rs3-sets.extractor";
import { Rs3ShopsExtractor } from "./rs3-shops.extractor";
import { Rs3SpellsExtractor } from "./rs3-spells.extractor";
import { Rs3SpawnExtractor } from "./rs3-spawn.extractor";
import { Rs3TemplateExtractor } from "./rs3-template.extractor";

/**
 * Wires the 16 RS3 extractors. Mirrors the OSRS {@link ExtractorsModule}.
 *
 * Every extractor here delegates its actual parsing to the OSRS pure
 * functions (e.g. `parseItemFromWikiData`) and only re-implements the
 * orchestration layer (DB read → parse → JSON write). RS3-specific markup
 * differences (different infoboxes, absent templates, …) will yield null /
 * empty results — those extractors can later be specialised per-game.
 */
@Module({
  imports: [Rs3DumpersModule, Rs3DatabaseModule],
  providers: [
    Rs3ActivitiesExtractor,
    Rs3ItemsExtractor,
    Rs3LocationsExtractor,
    Rs3MonstersExtractor,
    Rs3MusicExtractor,
    Rs3NewsExtractor,
    Rs3NpcsExtractor,
    Rs3PrayersExtractor,
    Rs3QuestsExtractor,
    Rs3RecipesExtractor,
    Rs3SceneryExtractor,
    Rs3SetsExtractor,
    Rs3ShopsExtractor,
    Rs3SpellsExtractor,
    Rs3SpawnExtractor,
    Rs3TemplateExtractor,
  ],
  exports: [
    Rs3ActivitiesExtractor,
    Rs3ItemsExtractor,
    Rs3LocationsExtractor,
    Rs3MonstersExtractor,
    Rs3MusicExtractor,
    Rs3NewsExtractor,
    Rs3NpcsExtractor,
    Rs3PrayersExtractor,
    Rs3QuestsExtractor,
    Rs3RecipesExtractor,
    Rs3SceneryExtractor,
    Rs3SetsExtractor,
    Rs3ShopsExtractor,
    Rs3SpellsExtractor,
    Rs3SpawnExtractor,
    Rs3TemplateExtractor,
  ],
})
export class Rs3ExtractorsModule {}
