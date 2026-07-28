# OSRS Cloud Wiki Scraper

Scrapes the [OSRS Wiki](https://oldschool.runescape.wiki/) via MediaWiki API, parses wikitext markup into structured JSON, and stores extracted data locally.

Also supports the [RS3 Wiki](https://runescape.wiki/) — see [RS3 pipeline](#rs3-pipeline) below.

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

## RS3 pipeline

The scraper supports a second, parallel pipeline targeting the RS3 wiki
(`https://runescape.wiki`). It is selected at boot via the `GAME` env var:

| Env var | Default | Purpose |
|---|---|---|
| `GAME` | `osrs` | Selects pipeline. `osrs` keeps the OSRS modules; `rs3` swaps in the RS3 ones. |
| `DB_PATH_RS3` | `data/database-rs3.sqlite` | SQLite file for RS3 pages. Two DB files — OSRS and RS3 never share. |
| `DATA_FOLDER_PATH_RS3` | `./data/rs3` | Extracted JSON root for RS3. |
| `WIKI_FOLDER_PATH_RS3` | `./wiki-data-rs3` | Raw wiki dump root for RS3. |

### Architecture (parallel modules, no OSRS code touched)

```
src/modules-rs3/
├── app/
│   ├── rs3-app.module.ts        # Root RS3 module — wired by AppModule when GAME=rs3
│   └── rs3-dev.service.ts       # Orchestrates RS3 dump → extract pipeline
├── wiki/
│   ├── rs3-wiki.module.ts
│   └── rs3-wiki-request.service.ts  # Subclass of WikiRequestService → runescape.wiki
├── database/
│   ├── rs3-database.module.ts
│   └── rs3-database.service.ts  # Subclass of DatabaseService → DB_PATH_RS3
├── dumpers/
│   ├── rs3-dumpers.module.ts
│   ├── rs3-page-list.dumper.ts
│   ├── rs3-page-content.dumper.ts
│   └── rs3-module.dumper.ts
└── extractors/
    ├── rs3-extractors.module.ts
    └── rs3-*.extractor.ts       # 16 extractors mirroring the OSRS ones
```

The RS3 wiki service and database service **subclass** their OSRS counterparts
(`WikiRequestService`, `DatabaseService`); OSRS behaviour is unchanged.
Output paths live in `src/constants/rs3-paths.ts` rooted at `data/rs3/`.

### Extractor reuse strategy

Each RS3 extractor delegates its parsing to the **OSRS pure function** (e.g.
`parseItemFromWikiData`, `parseMonsterFromContent`) and only re-implements
the orchestration layer (DB read → parse → JSON write). RS3-specific markup
differences (e.g. RS3 has no `{{LocLine}}`, no `Module:GELimits`) are noted
inline per extractor and yield null/empty fields until a specialised RS3
parser is written.

### RS3-specific tweaks already applied

- **News namespace**: RS3 `Update:` is ns=100 (verified via
  `meta=siteinfo&siprop=namespaces`). OSRS uses ns=112; RS3's ns=112 is
  `Exchange:`.
- **Monsters category**: RS3 uses `Category:Bestiary` (not
  `Category:Monsters` which has 0 pages).
- **GE items**: `Category:Grand Exchange items` exists on RS3 (same as OSRS).
- **Recipes**: RS3 uses `{{Infobox Recipe}}` (not `{{Recipe}}`). The RS3
  extractor normalises RS3 param names (`mat1qty` → `mat1quantity`, `tool`
  → `tools`, etc.) then delegates to the OSRS `parseRecipeProperties`.
- **GE limits**: RS3 has no `Module:GELimits/data.json` counterpart — every
  RS3 item gets `limit = 0`.
- **Music / news URLs**: the OSRS pure parsers hardcode
  `oldschool.runescape.wiki`; the RS3 extractors post-process the host to
  `runescape.wiki`.
- **OSRS-only templates** (return 0 on RS3, producing empty output — not
  bugs, just content differences): `{{ItemSpawnLine}}`, `{{CostLine}}`.

### Running

```bash
# OSRS (default)
GAME=osrs npm run start

# RS3
GAME=rs3 DB_PATH_RS3=data/database-rs3.sqlite npm run start
```
