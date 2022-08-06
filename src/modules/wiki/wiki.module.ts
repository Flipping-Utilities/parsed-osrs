import { Module } from '@nestjs/common';
import { WikiRequestService } from './wikiRequest.service';

@Module({
  providers: [WikiRequestService],
  exports: [WikiRequestService],
})
export class WikiModule {}
