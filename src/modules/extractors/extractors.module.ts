import { Module } from '@nestjs/common';
import { DumpersModule } from '../dumpers/dumpers.module';
import { WikiModule } from '../wiki/wiki.module';
import { ItemsExtractor } from './items.extractor';
import { MonstersExtractor } from './monsters.extractor';
import { RecipesExtractor } from './recipes.extractor';
import { SetsExtractor } from './sets.extractor';
import { ShopsExtractor } from './shops.extractor';
import { SpawnExtractor } from './spawn.extractor';

@Module({
  imports: [WikiModule, DumpersModule],
  providers: [
    ItemsExtractor,
    SetsExtractor,
    RecipesExtractor,
    ShopsExtractor,
    SpawnExtractor,
    MonstersExtractor,
  ],
  exports: [
    ItemsExtractor,
    SetsExtractor,
    SpawnExtractor,
    RecipesExtractor,
    ShopsExtractor,
    MonstersExtractor,
  ],
})
export class ExtractorsModule {}
