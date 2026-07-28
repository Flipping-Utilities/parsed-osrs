import { createClient } from "@libsql/client";
import { Injectable, type OnModuleInit } from "@nestjs/common";
import { drizzle } from "drizzle-orm/libsql";
import { eq, sql } from "drizzle-orm";
import { pathToFileURL } from "node:url";
import * as path from "path";
import * as schema from "./schema";

/**
 * SQLite-backed storage for dumped wiki pages and their page tags.
 *
 * Two connection modes, selected automatically by env:
 *
 * - **Remote (Turso / any hosted libSQL)** — set `LIBSQL_URL`
 *   (`libsql://<db>.turso.io` or similar) and optionally `LIBSQL_AUTH_TOKEN`.
 *   Used by GitHub Actions cron jobs so state persists across runs without
 *   any file sync.
 * - **Local file** — fallback when `LIBSQL_URL` is unset. The file path
 *   comes from `DB_PATH` (OSRS) or `DB_PATH_RS3` (RS3, via subclass override).
 *
 * On startup the two tables (`wiki_page`, `page_tag`) are created with
 * `CREATE TABLE IF NOT EXISTS` so a fresh database — local file or Turso —
 * is ready to use without a `drizzle-kit push` step. The DDL matches the
 * drizzle-kit-generated migration exactly.
 *
 * Schema creation happens in {@link onModuleInit} rather than the constructor
 * because drizzle-orm's libSQL driver is async — `db.run()` returns a Promise
 * that must be awaited before any queries can run. Constructors can't await,
 * so we let NestJS's lifecycle block app boot until tables exist.
 */
@Injectable()
export class DatabaseService implements OnModuleInit {
  protected resolveLibSqlUrl(): string | undefined {
    return process.env.LIBSQL_URL;
  }

  protected resolveLibSqlAuthToken(): string | undefined {
    return process.env.LIBSQL_AUTH_TOKEN;
  }

  /**
   * Local SQLite path. Only consulted when {@link resolveLibSqlUrl} returns
   * undefined. Subclasses override to use a different env var (e.g.
   * `DB_PATH_RS3`). Falls back to `data/database.sqlite` when the env var is
   * unset so the scraper still works with zero configuration.
   */
  protected resolveDbPath(): string {
    return process.env.DB_PATH || "data/database.sqlite";
  }

  readonly db: ReturnType<typeof drizzle<typeof schema>>;

  constructor() {
    const tursoUrl = this.resolveLibSqlUrl();
    const client =
      tursoUrl !== undefined
        ? createClient({
            url: tursoUrl,
            ...(this.resolveLibSqlAuthToken() && {
              authToken: this.resolveLibSqlAuthToken(),
            }),
          })
        : // `pathToFileURL` produces a valid `file:///...` URL on Linux/macOS
          // and `file:///C:/...` on Windows. The previous hand-rolled
          // `file:/${absPath}` produced `file://app/...` on Linux which libsql
          // parsed as having host "app" — see
          // https://github.com/libsql/libsql-client-ts#supported-urls.
          createClient({
            url: pathToFileURL(path.join(process.cwd(), this.resolveDbPath())).toString(),
          });

    this.db = drizzle(client, { schema });
    // Schema creation is deferred to onModuleInit — see class doc.
  }

  getDb() {
    return this.db;
  }

  /**
   * NestJS lifecycle hook. Runs after the service is instantiated but before
   * any consumer can use it, and the framework awaits it before declaring
   * the module ready. That's exactly what we need: a synchronous-feeling
   * "tables exist" guarantee built on top of an async driver.
   */
  async onModuleInit(): Promise<void> {
    await this.ensureSchema();
  }

  /**
   * Creates the `wiki_page`, `page_tag`, and `kv` tables if they don't
   * already exist. Idempotent — safe to call on every boot, even against a
   * DB that already has the tables. Verified byte-identical to
   * `drizzle-kit generate` output.
   */
  protected async ensureSchema(): Promise<void> {
    await this.db.run(sql`
      CREATE TABLE IF NOT EXISTS page_tag (
        page_id integer NOT NULL,
        tag text NOT NULL,
        PRIMARY KEY(page_id, tag)
      )
    `);
    await this.db.run(sql`
      CREATE TABLE IF NOT EXISTS wiki_page (
        id integer PRIMARY KEY NOT NULL,
        aliases text DEFAULT '[]',
        html text,
        model text,
        namespace integer,
        parent_id integer,
        revision_id integer,
        full_revision_id integer,
        text text,
        timestamp integer,
        title text NOT NULL
      )
    `);
    await this.db.run(sql`
      CREATE TABLE IF NOT EXISTS kv (
        key text PRIMARY KEY NOT NULL,
        value text NOT NULL
      )
    `);
  }

  /**
   * Read a value from the {@link schema.Kv} table. Returns `undefined` when
   * the key doesn't exist (treated as "never set" by callers — e.g. a fresh
   * DB with no recorded `last_wiki_dump_at` triggers an immediate dump).
   */
  async getKv(key: string): Promise<string | undefined> {
    const rows = await this.db
      .select({ value: schema.Kv.value })
      .from(schema.Kv)
      .where(eq(schema.Kv.key, key))
      .limit(1);
    return rows[0]?.value;
  }

  /**
   * Upsert a value into the {@link schema.Kv} table. Used for singleton
   * state like the last-dump timestamp.
   */
  async setKv(key: string, value: string): Promise<void> {
    await this.db
      .insert(schema.Kv)
      .values({ key, value })
      .onConflictDoUpdate({
        target: schema.Kv.key,
        set: { value },
      })
      .run();
  }
}
