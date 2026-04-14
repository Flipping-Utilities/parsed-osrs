# OSRS Cloud Wiki Scraper

Scrapes the [OSRS Wiki](https://oldschool.runescape.wiki/) via MediaWiki API, parses wikitext markup into structured JSON, and stores extracted data locally.

## Repository Layout

```
├── src/
│   ├── main.ts            # Bootstrap — creates NestJS application context
│   ├── constants/
│   │   ├── paths.ts       # All file output paths (DATA_FOLDER, ITEMS_FOLDER, etc.)
│   │   ├── tags.ts        # PageTags enum — used to categorize wiki pages by type
│   │   └── test-pages.ts  # TestPage IDs mapped to wiki page IDs for test fixtures
│   ├── types/
│   │   ├── index.ts       # Re-exports all type modules
│   │   ├── item.ts        # Item, EquipmentStats, ItemSpawn interfaces
│   │   ├── monster.ts     # Monster interface
│   │   ├── recipe.ts      # Recipe interfaces
│   │   ├── sets.ts        # Item set interfaces
│   │   └── shops.ts       # Shop interfaces
│   └── modules/
│       ├── app/
│       │   ├── app.module.ts       # Root NestJS module — wires all sub-modules
│       │   ├── app.controller.ts   # Health check endpoint (GET / → "Online")
│       │   └── dev.service.ts      # Entry point — orchestrates dump → extract pipeline
│       ├── database/
│       │   ├── database.module.ts  # Database module
│       │   ├── database.service.ts # Drizzle ORM + libsql (SQLite) connection
│       │   └── schema.ts           # Drizzle schema: WikiPage, PageTag tables
│       ├── dumpers/
│       │   ├── dumpers.module.ts
│       │   ├── page-list.dumper.ts    # Fetches page lists from wiki API + tags pages
│       │   └── page-content.dumper.ts # Fetches full page content (wikitext + HTML)
│       ├── extractors/
│       │   ├── extractors.module.ts
│       │   ├── items.extractor.ts     # Item + EquipmentStats extraction
│       │   ├── monsters.extractor.ts  # Monster + drop table extraction
│       │   ├── recipes.extractor.ts   # Recipe/skill-based creation extraction
│       │   ├── sets.extractor.ts      # Item set decomposition extraction
│       │   ├── shops.extractor.ts     # Shop inventory extraction
│       │   ├── spawn.extractor.ts     # Item spawn location extraction
│       │   ├── template.extractor.ts  # Generic template extraction
│       │   └── *.spec.ts              # Unit tests alongside each extractor
│       └── wiki/
│           ├── wiki.module.ts
│           └── wikiRequest.service.ts  # MediaWiki API client with pagination
├── test/
│   ├── test-utils.ts       # loadTestPage() — reads JSON fixtures by page ID
│   └── pages/              # Wiki page fixtures (JSON) for unit tests
│       ├── 13809.json      # e.g. "1/5ths full bucket" (non-equipable item)
│       ├── 386331.json     # e.g. "3rd age felling axe" (equipable, combat stats)
│       └── ...
└── vitest.config.ts        # Vitest config
```

## Architecture

### Two-Phase Pipeline

1. **Dump phase** — Fetch raw data from OSRS Wiki API and store in SQLite + JSON files
   - `PageListDumper`: Fetches page lists by category (Items, Monsters, Shops, etc.) and tags them in DB
   - `PageContentDumper`: Fetches full page content (wikitext + rendered HTML) per page, stores in DB
   - Redirects/aliases are resolved and stored alongside pages

2. **Extract phase** — Parse stored wiki markup into structured JSON
   - Each extractor reads page wikitext from DB, parses `{{Infobox ...}}` templates via `infobox-parser`, and outputs typed JSON
   - Extractors write results to `data/items/`, `data/monsters/`, etc.
   - The pipeline runs automatically via `DevService` on app startup

### Key Patterns

- **Wikitext parsing**: Uses `infobox-parser` to parse MediaWiki infobox templates. The `{|` table syntax is replaced with `{a|` before parsing to avoid parser conflicts. `{{sic}}` tags are stripped.
- **Extractors follow a consistent pattern**: Export a pure function (e.g. `parseItemFromWikiData`) that takes parsed wiki data + page metadata and returns typed objects. The `@Injectable` class wraps this for NestJS DI and handles DB reads/writes.
- **Multi-variant items**: Some wiki pages define multiple item variants (e.g. potion doses) using numbered keys (`id2`, `name2`, etc.). The `hasMultiple` check detects this and splits into separate items with `relatedItems` cross-links.
- **Type coercion from wiki**: Wiki infobox values are strings like `"+82"`, `"Yes"`, `"-15"`. Numeric fields use `Number(value) || 0`, boolean fields use `=== 'Yes' || === true`.
- **Page tags**: Pages are categorized by `PageTags` enum (item, monster, shop, etc.) in a `page_tag` join table. This replaces older file-based page lists.

### Data Formats

**Wiki page in DB/JSON** (input to extractors):
```ts
{
  pageid: number;
  title: string;
  text: string;       // Raw wikitext markup
  html: string;       // Rendered HTML
  aliases: string[];  // Redirect page names
  revisionId: number;
}
```

**Test page fixtures** (`wiki-scraper/test/pages/{pageId}.json`):
```ts
{ id: number; title: string; text: string; html: string; aliases: string[]; }
```

Test fixtures are created by converting wiki page dumps from `data/wiki-pages/` — `rawContent` → `text`, `content` → `html`, `redirects` → `aliases`.

## Testing

```bash
# From wiki-scraper/ directory
npx vitest run                  # Run all tests
npx vitest run src/modules/extractors/items.extractor.spec.ts  # Single file
```

- **Framework**: Vitest with `globals: true`
- **Fixtures**: Real wiki pages stored as JSON in `wiki-scraper/test/pages/`. Referenced by page ID via `TestPages` constant in `src/constants/test-pages.ts`.
- **Pattern**: Each extractor has a `.spec.ts` file alongside it. Tests use `loadTestPage()` + `parseInfo()` to reproduce the real parsing pipeline, then assert on the output.

### Adding a new test fixture

1. Find the wiki page ID: search `data/wiki-pages/` or query `data/items/all-items.json`
2. Convert the wiki dump to test format:
   ```ts
   { id: wikiPage.pageid, title: wikiPage.pagename,
     text: wikiPage.rawContent, html: wikiPage.content,
     aliases: wikiPage.redirects || [] }
   ```
3. Save as `wiki-scraper/test/pages/{pageId}.json`
4. Add the page ID to `TestPages` in `src/constants/test-pages.ts`

## Dependencies

- **NestJS** — Application framework, DI, module system
- **Drizzle ORM + libsql** — SQLite database for page storage
- **infobox-parser** — Parses MediaWiki `{{Infobox}}` templates into JS objects
- **axios** — HTTP client for MediaWiki API
- **cheerio** — HTML parsing (used for monster drop tables)
- **vitest** — Test runner

## Environment Variables

Required (validated by NestJS ConfigModule):
- `DATA_FOLDER_PATH` — Path for extracted JSON output
- `WIKI_FOLDER_PATH` — Path for raw wiki page dumps
- `DB_PATH` — SQLite database file path (relative to cwd)
- `NODE_ENV` — development | production | test | provision
