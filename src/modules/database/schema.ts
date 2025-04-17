import {
  integer,
  primaryKey,
  sqliteTable,
  text,
} from 'drizzle-orm/sqlite-core';

export const WikiPage = sqliteTable('wiki_page', {
  id: integer('id').primaryKey({ autoIncrement: false }).notNull(),
  title: text('title').notNull(),
  namespace: integer('namespace'),
  revisionId: integer('revision_id'),
  parentId: integer('parent_id'),
  timestamp: integer('timestamp', { mode: 'timestamp' }),
  model: text('model'),
  text: text('text'),
  html: text('html'),
});

export const PageTag = sqliteTable(
  'page_tag',
  {
    wikiPageId: integer('page_id').notNull(),
    // Some of the tags might reference page that don't exist: We don't want to fail the whole query if that happens
    // .references(() => WikiPage.id, { onDelete: 'cascade' }),
    tag: text('tag').notNull(),
  },
  (table) => [primaryKey({ columns: [table.wikiPageId, table.tag] })]
);
