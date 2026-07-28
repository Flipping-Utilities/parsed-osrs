import { Injectable, Logger } from "@nestjs/common";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";
import path from "path";
import { MODULES_FOLDER } from "../../constants/rs3-paths";
import { Rs3WikiRequestService } from "../wiki/rs3-wiki-request.service";

const MODULE_BATCH_SIZE = 50;
const WINDOWS_RESERVED_CHARS = /[:<>"|?*]/g;
const WINDOWS_TRIM_TRAILING = /[\s.]+$/;

function sanitizeModuleFilename(title: string): string {
  const base = title
    .replace(/^Module:/, "")
    .replace(/\.\.\//g, "")
    .replace(/[\\/]/g, "__")
    .replace(WINDOWS_RESERVED_CHARS, "_")
    .replace(WINDOWS_TRIM_TRAILING, "");
  return `${base}.lua`;
}

/**
 * RS3 counterpart of {@link ModuleDumper}. Fetches every Module: namespace
 * page from the RS3 wiki and writes raw source under `data/rs3/modules/`.
 * Algorithm and on-disk layout are identical to the OSRS dumper.
 */
@Injectable()
export class Rs3ModuleDumper {
  private logger = new Logger(Rs3ModuleDumper.name);

  private readonly MODULE_NAMESPACE = 828;

  private readonly MODULE_INDEX_FILE = path.join(MODULES_FOLDER, ".module-index.json");

  constructor(private readonly wikiRequestService: Rs3WikiRequestService) {}

  async fetchModulePageList(): Promise<
    Array<{ pageid: number; title: string; namespace: number }>
  > {
    const properties = {
      action: "query",
      list: "allpages",
      apnamespace: String(this.MODULE_NAMESPACE),
      aplimit: "max",
      format: "json",
      apfilterredir: "nonredirects",
    };

    const pages = await this.wikiRequestService.queryAllPagesPromise<{
      pageid: number;
      title: string;
      ns: number;
    }>("apcontinue", "allpages", properties);

    return pages.map((p) => ({
      pageid: p.pageid,
      title: p.title,
      namespace: p.ns,
    }));
  }

  async dumpAllModules(): Promise<void> {
    this.logger.log("Start: Dumping all modules (RS3)");
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
        if (!source) continue;

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
              page.pagename,
            )}: ${e instanceof Error ? e.message : String(e)}`,
          );
        }
      }

      this.logger.debug(
        `Modules: ${Math.min(i + MODULE_BATCH_SIZE, pageIds.length)}/${pageIds.length} ` +
          `(fetched ${fetched}, written ${written}, skipped ${skipped}, failed ${failed})`,
      );
    }

    this.saveModuleIndex(knownRevisions);
    this.logger.log(
      `End: Dumping all modules (fetched ${fetched}, written ${written}, skipped ${skipped}, failed ${failed})`,
    );
  }

  private toFilePath(title: string): string {
    return path.join(MODULES_FOLDER, sanitizeModuleFilename(title));
  }

  private loadModuleIndex(): Record<string, number> {
    if (!existsSync(this.MODULE_INDEX_FILE)) return {};
    try {
      const raw = readFileSync(this.MODULE_INDEX_FILE, "utf-8");
      const parsed = JSON.parse(raw);
      return parsed && typeof parsed === "object" ? parsed : {};
    } catch (e) {
      this.logger.warn(
        `Failed to read module index at ${this.MODULE_INDEX_FILE}; treating all modules as changed`,
        e,
      );
      return {};
    }
  }

  private saveModuleIndex(index: Record<string, number>): void {
    writeFileSync(this.MODULE_INDEX_FILE, JSON.stringify(index, null, 2));
  }
}
