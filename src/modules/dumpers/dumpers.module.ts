import { Module } from '@nestjs/common';
import { DatabaseModule } from '../database/database.module';
import { WikiModule } from '../wiki/wiki.module';
import { ModuleDumper } from './module.dumper';
import { PageContentDumper } from './page-content.dumper';
import { PageListDumper } from './page-list.dumper';

@Module({
  imports: [WikiModule, DatabaseModule],
  providers: [PageListDumper, PageContentDumper, ModuleDumper],
  exports: [PageListDumper, PageContentDumper, ModuleDumper],
})
export class DumpersModule {}
