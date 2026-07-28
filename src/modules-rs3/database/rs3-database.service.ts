import { Injectable } from "@nestjs/common";
import { DatabaseService } from "../../modules/database/database.service";

/**
 * RS3-flavoured {@link DatabaseService}.
 *
 * Three env-var overrides (all RS3-specific suffixes of the OSRS ones):
 *
 * - `LIBSQL_URL_RS3` — Turso/libSQL URL for the RS3 database
 * - `LIBSQL_AUTH_TOKEN_RS3` — auth token for the RS3 database
 * - `DB_PATH_RS3` — local SQLite path, fallback when `LIBSQL_URL_RS3` is unset
 *
 * Schema creation is inherited from the base class (`ensureSchema()` runs in
 * the parent constructor and is idempotent).
 */
@Injectable()
export class Rs3DatabaseService extends DatabaseService {
  protected resolveLibSqlUrl(): string | undefined {
    return process.env.LIBSQL_URL_RS3;
  }

  protected resolveLibSqlAuthToken(): string | undefined {
    return process.env.LIBSQL_AUTH_TOKEN_RS3;
  }

  protected resolveDbPath(): string {
    return (process.env.DB_PATH_RS3 as string) || "data/database-rs3.sqlite";
  }
}
