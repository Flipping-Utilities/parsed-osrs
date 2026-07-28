import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_SPELLS } from "../../constants/rs3-paths";
import { Spell } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseSpellFromContent } from "../../modules/extractors/spells.extractor";
import { Rs3ItemsExtractor } from "./rs3-items.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/** RS3 counterpart of {@link SpellsExtractor}. */
@Injectable()
export class Rs3SpellsExtractor {
  private logger = new Logger(Rs3SpellsExtractor.name);
  private cachedSpells: Spell[] | null = null;

  constructor(
    private readonly itemExtractor: Rs3ItemsExtractor,
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllSpells(): Promise<Spell[]> {
    this.logger.log("Start: Extracting spells (RS3)");

    const spellPages = await this.pageListDumper.getPagesFromTag(PageTags.SPELL);
    const length = spellPages.length;
    const spells: Spell[] = [];
    let i = 0;
    for await (const page of spellPages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Spells: ${i}/${length}`);
      }
      const spell = await this.extractSpellFromPageId(page.id);
      if (spell) {
        spells.push(spell);
      }
    }

    spells.sort((a, b) => a.name.localeCompare(b.name));
    if (spells.length) {
      writeFileSync(ALL_SPELLS, JSON.stringify(spells, null, 2));
    }

    this.logger.log("Done: Extracting spells (RS3)");
    return spells;
  }

  public getAllSpells(): Spell[] | null {
    if (!this.cachedSpells) {
      if (!existsSync(ALL_SPELLS)) {
        return null;
      }
      try {
        this.cachedSpells = JSON.parse(readFileSync(ALL_SPELLS, "utf8"));
      } catch (e) {
        this.logger.warn("all spells has invalid content", e);
      }
    }
    return this.cachedSpells;
  }

  private async extractSpellFromPageId(pageId: number): Promise<Spell | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    return parseSpellFromContent(
      page.text,
      page.title,
      page.aliases || [],
      (name) => this.itemExtractor.getItemByName(name) ?? null,
    );
  }
}
