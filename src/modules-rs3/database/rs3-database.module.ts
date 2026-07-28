import { Module } from "@nestjs/common";
import { Rs3DatabaseService } from "./rs3-database.service";

/**
 * Provides {@link Rs3DatabaseService} to the RS3 dumper/extractor modules.
 *
 * Provided as the concrete class (not the `DatabaseService` base) so that
 * RS3 modules can only ever see the RS3 DB. The OSRS `DatabaseModule` is
 * untouched and continues to provide its own `DatabaseService` to OSRS
 * modules.
 */
@Module({
  providers: [Rs3DatabaseService],
  exports: [Rs3DatabaseService],
})
export class Rs3DatabaseModule {}
