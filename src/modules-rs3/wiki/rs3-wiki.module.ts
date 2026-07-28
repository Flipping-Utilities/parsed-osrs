import { Module } from "@nestjs/common";
import { Rs3WikiRequestService } from "./rs3-wiki-request.service";

/**
 * Provides {@link Rs3WikiRequestService} to the RS3 dumper/extractor modules.
 *
 * The concrete class is both provided and exported so that downstream RS3
 * modules can inject it directly by class — keeping the OSRS `WikiModule`
 * untouched and avoiding the need for a separate DI token.
 */
@Module({
  providers: [Rs3WikiRequestService],
  exports: [Rs3WikiRequestService],
})
export class Rs3WikiModule {}
