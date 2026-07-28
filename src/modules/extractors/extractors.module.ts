import { Module } from "@nestjs/common";
import { DatabaseModule } from "../database/database.module";
import { DumpersModule } from "../dumpers/dumpers.module";
import { WikiModule } from "../wiki/wiki.module";
import { ActivitiesExtractor } from "./activities.extractor";
import { ItemsExtractor } from "./items.extractor";
import { LocationsExtractor } from "./locations.extractor";
import { MonstersExtractor } from "./monsters.extractor";
import { MusicExtractor } from "./music.extractor";
import { NewsExtractor } from "./news.extractor";
import { NpcsExtractor } from "./npcs.extractor";
import { PrayersExtractor } from "./prayers.extractor";
import { QuestsExtractor } from "./quests.extractor";
import { RecipesExtractor } from "./recipes.extractor";
import { SceneryExtractor } from "./scenery.extractor";
import { SetsExtractor } from "./sets.extractor";
import { ShopsExtractor } from "./shops.extractor";
import { SpellsExtractor } from "./spells.extractor";
import { SpawnExtractor } from "./spawn.extractor";
import { TemplateExtractor } from "./template.extractor";

@Module({
  imports: [WikiModule, DumpersModule, DatabaseModule],
  providers: [
    ActivitiesExtractor,
    ItemsExtractor,
    LocationsExtractor,
    MonstersExtractor,
    MusicExtractor,
    NewsExtractor,
    NpcsExtractor,
    PrayersExtractor,
    QuestsExtractor,
    RecipesExtractor,
    SceneryExtractor,
    SetsExtractor,
    ShopsExtractor,
    SpellsExtractor,
    SpawnExtractor,
    TemplateExtractor,
  ],
  exports: [
    ActivitiesExtractor,
    ItemsExtractor,
    LocationsExtractor,
    MonstersExtractor,
    MusicExtractor,
    NewsExtractor,
    NpcsExtractor,
    PrayersExtractor,
    QuestsExtractor,
    RecipesExtractor,
    SceneryExtractor,
    SetsExtractor,
    ShopsExtractor,
    SpellsExtractor,
    SpawnExtractor,
    TemplateExtractor,
  ],
})
export class ExtractorsModule {}
