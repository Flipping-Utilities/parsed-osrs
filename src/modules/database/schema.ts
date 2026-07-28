import { integer, primaryKey, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const WikiPage = sqliteTable("wiki_page", {
  id: integer("id").primaryKey({ autoIncrement: false }).notNull(),
  aliases: text("aliases", { mode: "json" }).$type<string[]>().default([]),
  html: text("html"),
  model: text("model"),
  namespace: integer("namespace"),
  parentId: integer("parent_id"),
  revisionId: integer("revision_id"),
  // The revision id from which the last full page was fetched
  // To avoid re-downloading pages that are already up-to-date.
  fullfetchRevisionId: integer("full_revision_id"),
  text: text("text"),
  timestamp: integer("timestamp", { mode: "timestamp" }),
  title: text("title").notNull(),
});

export const PageTag = sqliteTable(
  "page_tag",
  {
    wikiPageId: integer("page_id").notNull(),
    // Some of the tags might reference page that don't exist: We don't want to fail the whole query if that happens
    // .references(() => WikiPage.id, { onDelete: 'cascade' }),
    tag: text("tag").notNull(),
  },
  (table) => [primaryKey({ columns: [table.wikiPageId, table.tag] })],
);

/**
 * Generic key-value store for tiny singleton values that don't merit their
 * own table — e.g. the timestamp of the last successful wiki dump, used by
 * the dev services to short-circuit redundant dumps.
 */
export const Kv = sqliteTable("kv", {
  key: text("key").primaryKey().notNull(),
  value: text("value").notNull(),
});
