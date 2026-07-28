import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import * as Joi from "joi";
import { DatabaseModule } from "../database/database.module";
import { DumpersModule } from "../dumpers/dumpers.module";
import { ExtractorsModule } from "../extractors/extractors.module";
import { Rs3AppModule } from "../../modules-rs3/app/rs3-app.module";
import { AppController } from "./app.controller";
import { DevService } from "./dev.service";

/**
 * `GAME=rs3` swaps the entire dumper/extractor pipeline for its RS3
 * counterpart; anything else (default, `osrs`, undefined, …) keeps the OSRS
 * pipeline active. The two pipelines never run together in the same process
 * — they each have their own SQLite DB, wiki origin, and output folder.
 */
const game = (process.env.GAME || "osrs").toLowerCase();
const isRs3 = game === "rs3";

const pipelineImports = isRs3 ? [Rs3AppModule] : [DumpersModule, ExtractorsModule, DatabaseModule];
const pipelineProviders = isRs3 ? [] : [DevService];

@Module({
  imports: [
    ...pipelineImports,
    ConfigModule.forRoot({
      validationSchema: Joi.object({
        DATA_FOLDER_PATH: Joi.string().required(),
        WIKI_FOLDER_PATH: Joi.string().required(),
        // Local fallback paths (used only when the LIBSQL_URL* vars are unset)
        DB_PATH: Joi.string().allow("").optional(),
        // RS3-only; only required when GAME=rs3 (loosely: allow empty so
        // `abortEarly` doesn't fail the OSRS run).
        DATA_FOLDER_PATH_RS3: Joi.string().allow("").optional(),
        WIKI_FOLDER_PATH_RS3: Joi.string().allow("").optional(),
        DB_PATH_RS3: Joi.string().allow("").optional(),
        // Turso / hosted libSQL. When set, the scraper connects remotely and
        // the local DB_PATH* vars are ignored.
        LIBSQL_URL: Joi.string().allow("").optional(),
        LIBSQL_AUTH_TOKEN: Joi.string().allow("").optional(),
        LIBSQL_URL_RS3: Joi.string().allow("").optional(),
        LIBSQL_AUTH_TOKEN_RS3: Joi.string().allow("").optional(),
        GAME: Joi.string().valid("osrs", "rs3").default("osrs"),
        // When "true", both dev services skip dumpRedirectList. Used by the
        // daily cron to skip the ~30 min alias sweep; the weekly run leaves
        // it unset so aliases refresh.
        SKIP_REDIRECT_REFRESH: Joi.string()
          .valid("true", "false")
          .default("false"),
        // Minimum hours between wiki dumps. When the previous dump started
        // within this window, the dev service skips the dump phase and only
        // re-extracts from the existing DB contents. 
        MIN_REFRESH_HOURS: Joi.number().min(0).default(24),
        NODE_ENV: Joi.string()
          .valid("development", "production", "test", "provision")
          .default("development"),
        PORT: Joi.number().default(3000),
      }),
      validationOptions: {
        abortEarly: true,
      },
    }),
  ],
  controllers: [AppController],
  providers: pipelineProviders,
})
export class AppModule {}
