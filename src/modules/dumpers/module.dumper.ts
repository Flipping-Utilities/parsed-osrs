import { Injectable, Logger } from '@nestjs/common';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import path from 'path';
import { MODULES_FOLDER } from '../../constants/paths';
import { WikiRequestService } from '../wiki/wikiRequest.service';

// MediaWiki allows up to 50 pageids per request for anonymous/bot users
// without the `max` limit. Match MAX_PAGEIDS_PER_REQUEST in WikiRequestService
// so we chunk explicitly here (rather than relying on the service's internal
// chunking) — that way progress logs are per-batch and a fresh delta index
// can be persisted after each batch instead of only at the end.
const MODULE_BATCH_SIZE = 50;

// Characters that Windows forbids in filenames (NTFS / FAT). Wiki titles
// routinely contain `:` (namespace prefixes like `User:Foo` embedded in
// subpage paths) which would cause ENOENT on Windows if left as-is.
const WINDOWS_RESERVED_CHARS = /[:<>"|?*]/g;

/**
 * Strips the `Module:` namespace prefix and flattens a wiki page title into a
 * single safe filename.
 *
 * - `/` and `\` (path separators) → `__`, matching the historical convention
 *   that keeps each module as a flat file rather than nested directories.
 * - Windows-reserved characters (`: < > " | ? *`) → `_`. These appear in real
 *   wiki titles — `:` especially (`User:Spoiledduc`, `Template:Foo`, even
 *   `Module:Module:Sandbox/…`) and would crash `writeFileSync` on Windows.
 * - `../` traversal sequences are removed entirely.
 *
 * Exported so it can be unit-tested without touching the filesystem.
 */
export function sanitizeModuleFilename(title: string): string {
  return title
    .replace(/^Module:/, '')
    .replace(/\.\.\//g, '')
    .replace(/[\\/]/g, '__')
    .replace(WINDOWS_RESERVED_CHARS, '_');
}

@Injectable()
export class ModuleDumper {
  private logger = new Logger(ModuleDumper.name);

  // MediaWiki Module namespace index
  private readonly MODULE_NAMESPACE = 828;

  // Sidecar JSON written next to the module files: maps `Module:Title` to the
  // last persisted revision id. Read on startup so unchanged modules can be
  // skipped without re-writing the file (saves disk I/O on reruns).
  private readonly MODULE_INDEX_FILE = path.join(
    MODULES_FOLDER,
    '.module-index.json'
  );

  constructor(private readonly wikiRequestService: WikiRequestService) {}

  /**
   * Fetches the list of all pages in the Module: namespace (ns=828).
   */
  async fetchModulePageList(): Promise<
    Array<{ pageid: number; title: string; namespace: number }>
  > {
    const properties = {
      action: 'query',
      list: 'allpages',
      apnamespace: String(this.MODULE_NAMESPACE),
      aplimit: 'max',
      format: 'json',
      apfilterredir: 'nonredirects',
    };

    const pages = await this.wikiRequestService.queryAllPagesPromise<{
      pageid: number;
      title: string;
      ns: number;
    }>('apcontinue', 'allpages', properties);

    return pages.map((p) => ({
      pageid: p.pageid,
      title: p.title,
      namespace: p.ns,
    }));
  }

  /**
   * Dumps the raw source of every Module: page to disk, preserving the
   * subpage path (e.g. Module:GELimits/data → modules/GELimits__data).
   *
   * Two optimisations over the original per-module `?action=raw` loop:
   *
   * 1. **Batched fetch (≈50× fewer HTTP requests).** Module source is pulled
   *    via `WikiRequestService.queryPagesByIds` (50 pageids per request,
   *    `prop=revisions&rvprop=content`) instead of one `action=raw` request
   *    per module. Both endpoints return the latest revision's wikitext —
   *    the only difference is the URL — so on-disk output is byte-identical.
   *
   * 2. **Delta skip (only re-write modules whose revid changed).** A sidecar
   *    `${MODULES_FOLDER}/.module-index.json` records the last persisted
   *    revid per module title. Modules whose revid is unchanged are skipped
   *    without touching the disk. The wiki is still queried for their
   *    metadata (one revision id per page, cheap), but no source is written.
   *
   * Throttling / retries / User-Agent are handled centrally by
   * {@link WikiRequestService}.
   */
  async dumpAllModules(): Promise<void> {
    this.logger.log('Start: Dumping all modules');
    const modules = await this.fetchModulePageList();
    this.logger.log(`Found ${modules.length} modules to dump`);

    mkdirSync(MODULES_FOLDER, { recursive: true });
    const knownRevisions = this.loadModuleIndex();

    let fetched = 0;
    let written = 0;
    let skipped = 0;
    let failed = 0;

    const pageIds = modules.map((m) => m.pageid);
    for (let i = 0; i < pageIds.length; i += MODULE_BATCH_SIZE) {
      const chunk = pageIds.slice(i, i + MODULE_BATCH_SIZE);
      const pages = await this.wikiRequestService.queryPagesByIds(chunk);
      fetched += pages.length;

      for (const page of pages) {
        const source = page.rawContent;
        // Match the old getRawText() skip: empty source means the module
        // has no wikitext (e.g. a redirect that slipped through, or a
        // genuinely empty page).
        if (!source) continue;

        // Delta skip: revid unchanged since last run → leave the file alone.
        if (knownRevisions[page.pagename] === page.revid) {
          skipped++;
          continue;
        }

        try {
          const filePath = this.toFilePath(page.pagename);
          mkdirSync(path.dirname(filePath), { recursive: true });
          writeFileSync(filePath, source);
          knownRevisions[page.pagename] = page.revid;
          written++;
        } catch (e) {
          failed++;
          this.logger.warn(
            `Failed to write module ${page.pagename} → ${this.toFilePath(
              page.pagename
            )}: ${e instanceof Error ? e.message : String(e)}`
          );
        }
      }

      this.logger.debug(
        `Modules: ${Math.min(i + MODULE_BATCH_SIZE, pageIds.length)}/${
          pageIds.length
        } ` +
          `(fetched ${fetched}, written ${written}, skipped ${skipped}, failed ${failed})`
      );
    }

    this.saveModuleIndex(knownRevisions);
    this.logger.log(
      `End: Dumping all modules (fetched ${fetched}, written ${written}, skipped ${skipped}, failed ${failed})`
    );
  }

  /**
   * Maps a wiki page title (Module:Foo/Bar) to an output file path via
   * {@link sanitizeModuleFilename}.
   */
  private toFilePath(title: string): string {
    return path.join(MODULES_FOLDER, sanitizeModuleFilename(title));
  }

  /**
   * Reads the persisted `{ title: revid }` map. Missing or malformed file →
   * empty map (next dump treats every module as new, which is the safe
   * fallback).
   */
  private loadModuleIndex(): Record<string, number> {
    if (!existsSync(this.MODULE_INDEX_FILE)) return {};
    try {
      const raw = readFileSync(this.MODULE_INDEX_FILE, 'utf-8');
      const parsed = JSON.parse(raw);
      return parsed && typeof parsed === 'object' ? parsed : {};
    } catch (e) {
      this.logger.warn(
        `Failed to read module index at ${this.MODULE_INDEX_FILE}; treating all modules as changed`,
        e
      );
      return {};
    }
  }

  private saveModuleIndex(index: Record<string, number>): void {
    writeFileSync(this.MODULE_INDEX_FILE, JSON.stringify(index, null, 2));
  }
}
