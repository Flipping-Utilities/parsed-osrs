import { Module } from '@nestjs/common';
import { DumpersModule } from '../dumpers/dumpers.module';
import { ExtractorsModule } from '../extractors/extractors.module';
import { AppController } from './app.controller';
import { DevService } from './dev.service';
import { ConfigModule } from '@nestjs/config';
import * as Joi from 'joi';
import { DatabaseModule } from 'src/modules/database/database.module';

@Module({
  imports: [
    DumpersModule,
    ExtractorsModule,
    DatabaseModule,
    ConfigModule.forRoot({
      validationSchema: Joi.object({
        DATA_FOLDER_PATH: Joi.string().required(),
        WIKI_FOLDER_PATH: Joi.string().required(),
        NODE_ENV: Joi.string()
          .valid('development', 'production', 'test', 'provision')
          .default('development'),
        PORT: Joi.number().default(3000),
      }),
      validationOptions: {
        abortEarly: true,
      },
    }),
  ],
  controllers: [AppController],
  providers: [DevService],
})
export class AppModule {}
