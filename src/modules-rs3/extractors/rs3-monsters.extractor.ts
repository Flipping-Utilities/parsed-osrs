import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_MONSTERS } from "../../constants/rs3-paths";
import { Monster } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseMonsterFromContent } from "../../modules/extractors/monsters.extractor";
import { Rs3ItemsExtractor } from "./rs3-items.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/**
 * RS3 counterpart of {@link MonstersExtractor}. Reuses the OSRS
 * `parseMonsterFromContent`. RS3 monster infoboxes use a similar shape but
 * don't carry OSRS-specific slayer/thrall/burn fields — those just stay at
 * their defaults.
 *
 * Known RS3 caveat: `{{LocLine}}` is OSRS-specific and won't be present on
 * RS3 monster pages, so `locations` will always come back empty. The extractor
 * still works; an RS3-specific location parser can be added later.
 */
@Injectable()
export class Rs3MonstersExtractor {
  private logger: Logger = new Logger(Rs3MonstersExtractor.name);
  private cachedMonsters: Monster[] | null = null;

  constructor(
    private itemExtractor: Rs3ItemsExtractor,
    private pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllMonsters() {
    this.logger.log("Start: Extracting monsters (RS3)");

    const monstersPage = await this.pageListDumper.getPagesFromTag(PageTags.MONSTER);
    const length = monstersPage.length;
    const monsters: Monster[] = [];
    let i = 0;
    for await (const page of monstersPage) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Monsters: ${i}/${length}`);
      }
      const monstersFromPage = await this.extractMonsterFromPageId(page.id);
      monsters.push(...monstersFromPage);
    }

    if (monsters.length) {
      writeFileSync(ALL_MONSTERS, JSON.stringify(monsters));
    }

    this.logger.log("Done: Extracting monsters (RS3)");
    return monsters;
  }

  public getAllMonsters(): Monster[] | null {
    if (!this.cachedMonsters) {
      const candidatePath = ALL_MONSTERS;
      if (!existsSync(candidatePath)) {
        return null;
      }
      const pageContent = readFileSync(candidatePath, "utf8");
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.log("all monsters has invalid content", e);
      }
      this.cachedMonsters = parsed;
    }
    return this.cachedMonsters;
  }

  private async extractMonsterFromPageId(pageId: number): Promise<Monster[]> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page) {
      this.logger.warn("Could not fetch page content from id", pageId);
      return [];
    }
    if (!page.text) {
      this.logger.warn("No text for monster", page.title, page.id);
      return [];
    }

    return parseMonsterFromContent(page.text, page.title, page.aliases || [], (name) =>
      this.itemExtractor.getItemByName(name),
    );
  }
}
