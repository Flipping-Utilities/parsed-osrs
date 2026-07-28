import { Module } from "@nestjs/common";
import { Rs3DatabaseModule } from "../database/rs3-database.module";
import { Rs3DumpersModule } from "../dumpers/rs3-dumpers.module";
import { Rs3ExtractorsModule } from "../extractors/rs3-extractors.module";
import { Rs3DevService } from "./rs3-dev.service";

/**
 * Root module for the RS3 pipeline. Imports the RS3 dumper + extractor
 * modules and provides {@link Rs3DevService}, which orchestrates the full
 * dump → extract flow against `runescape.wiki`.
 *
 * The {@link AppModule} registers this conditionally based on `GAME=rs3`.
 */
@Module({
  imports: [Rs3DumpersModule, Rs3ExtractorsModule, Rs3DatabaseModule],
  providers: [Rs3DevService],
})
export class Rs3AppModule {}
