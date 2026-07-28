import { Module } from "@nestjs/common";
import { Rs3DatabaseModule } from "../database/rs3-database.module";
import { Rs3WikiModule } from "../wiki/rs3-wiki.module";
import { Rs3ModuleDumper } from "./rs3-module.dumper";
import { Rs3PageContentDumper } from "./rs3-page-content.dumper";
import { Rs3PageListDumper } from "./rs3-page-list.dumper";

/**
 * Wires the three RS3 dumpers. Imports {@link Rs3WikiModule} and
 * {@link Rs3DatabaseModule} so the dumpers get the RS3 wiki client and the
 * RS3 SQLite database injected automatically.
 */
@Module({
  imports: [Rs3WikiModule, Rs3DatabaseModule],
  providers: [Rs3PageListDumper, Rs3PageContentDumper, Rs3ModuleDumper],
  exports: [Rs3PageListDumper, Rs3PageContentDumper, Rs3ModuleDumper],
})
export class Rs3DumpersModule {}
