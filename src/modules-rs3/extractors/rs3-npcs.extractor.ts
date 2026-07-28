import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_NPCS } from "../../constants/rs3-paths";
import { NPC } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseNpcFromContent } from "../../modules/extractors/npcs.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/** RS3 counterpart of {@link NpcsExtractor}. */
@Injectable()
export class Rs3NpcsExtractor {
  private logger = new Logger(Rs3NpcsExtractor.name);
  private cachedNpcs: NPC[] | null = null;

  constructor(
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllNpcs(): Promise<NPC[]> {
    this.logger.log("Start: Extracting NPCs (RS3)");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.NPC);
    const length = pages.length;
    const npcs: NPC[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`NPCs: ${i}/${length}`);
      }
      npcs.push(...(await this.extractNpcFromPageId(page.id)));
    }

    npcs.sort((a, b) => a.name.localeCompare(b.name));
    if (npcs.length) {
      writeFileSync(ALL_NPCS, JSON.stringify(npcs, null, 2));
    }

    this.logger.log("Done: Extracting NPCs (RS3)");
    return npcs;
  }

  public getAllNpcs(): NPC[] | null {
    if (!this.cachedNpcs) {
      if (!existsSync(ALL_NPCS)) {
        return null;
      }
      try {
        this.cachedNpcs = JSON.parse(readFileSync(ALL_NPCS, "utf8"));
      } catch (e) {
        this.logger.warn("all npcs has invalid content", e);
      }
    }
    return this.cachedNpcs;
  }

  private async extractNpcFromPageId(pageId: number): Promise<NPC[]> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return [];
    }
    return parseNpcFromContent(page.text, page.title, page.aliases || []);
  }
}
