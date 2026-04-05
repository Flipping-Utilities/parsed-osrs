/**
 * Usage: bun run scripts/dump-test-pages.ts [pageId1] [pageId2] ...
 * No args = dumps all pages referenced in testPages constant.
 */

import { createClient } from '@libsql/client';
import { drizzle } from 'drizzle-orm/libsql';
import * as schema from '../src/modules/database/schema';
import { inArray } from 'drizzle-orm';
import * as fs from 'fs';
import path from 'path';
import { TestPages } from '../src/constants/test-pages';

const DB_PATH = process.env.DB_PATH || 'data/database.sqlite';
const OUTPUT_DIR = path.resolve(__dirname, '../test/pages');

interface PageFixture {
  id: number;
  title: string;
  text: string | null;
  html: string | null;
  aliases: string[] | null;
}

async function main() {
  const client = createClient({ url: `file:${DB_PATH}` });
  const db = drizzle(client, { schema });

  fs.mkdirSync(OUTPUT_DIR, { recursive: true });

  const providedIds = process.argv
    .slice(2)
    .map(Number)
    .filter((n) => !isNaN(n));

  const pageIds =
    providedIds.length > 0 ? providedIds : Object.values(TestPages);

  const pages = await db
    .select({
      id: schema.WikiPage.id,
      title: schema.WikiPage.title,
      text: schema.WikiPage.text,
      html: schema.WikiPage.html,
      aliases: schema.WikiPage.aliases,
    })
    .from(schema.WikiPage)
    .where(inArray(schema.WikiPage.id, pageIds));

  for (const page of pages) {
    const fixture: PageFixture = {
      id: page.id,
      title: page.title,
      text: page.text,
      html: page.html,
      aliases: page.aliases,
    };

    const outPath = path.join(OUTPUT_DIR, `${page.id}.json`);
    fs.writeFileSync(outPath, JSON.stringify(fixture, null, 2));
    console.log(`Wrote ${outPath} (${page.title})`);
  }

  console.log(`\nDone: ${pages.length} pages dumped to ${OUTPUT_DIR}`);
}

main().catch(console.error);
