import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { eq } from "drizzle-orm";
import { ALL_QUESTS } from "../../constants/rs3-paths";
import { Quest } from "../../types";
import { PageTags } from "../../constants/tags";
import { WikiPage } from "../../modules/database/schema";
import {
  parseQuestFromContent,
  parseQuickGuideFromContent,
  buildQuickGuideTitle,
} from "../../modules/extractors/quests.extractor";
import { Rs3DatabaseService } from "../database/rs3-database.service";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/** RS3 counterpart of {@link QuestsExtractor}. */
@Injectable()
export class Rs3QuestsExtractor {
  private logger = new Logger(Rs3QuestsExtractor.name);
  private cachedQuests: Quest[] | null = null;

  constructor(
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
    private readonly databaseService: Rs3DatabaseService,
  ) {}

  public async extractAllQuests(): Promise<Quest[]> {
    this.logger.log("Start: Extracting quests (RS3)");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.QUEST);
    const length = pages.length;
    const quests: Quest[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 50 === 0) {
        this.logger.debug(`Quests: ${i}/${length}`);
      }
      const quest = await this.extractQuestFromPageId(page.id);
      if (quest) quests.push(quest);
    }

    quests.sort((a, b) => a.number - b.number);
    if (quests.length) {
      writeFileSync(ALL_QUESTS, JSON.stringify(quests, null, 2));
    }

    this.logger.log("Done: Extracting quests (RS3)");
    return quests;
  }

  public getAllQuests(): Quest[] | null {
    if (!this.cachedQuests) {
      if (!existsSync(ALL_QUESTS)) {
        return null;
      }
      try {
        this.cachedQuests = JSON.parse(readFileSync(ALL_QUESTS, "utf8"));
      } catch (e) {
        this.logger.warn("all quests has invalid content", e);
      }
    }
    return this.cachedQuests;
  }

  private async extractQuestFromPageId(pageId: number): Promise<Quest | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    const quest = parseQuestFromContent(page.text, page.title, page.aliases || []);
    if (!quest) return null;

    const guideTitle = buildQuickGuideTitle(page.title);
    const guidePage = await this.getDBPageByTitle(guideTitle);
    if (guidePage?.text) {
      const quickGuide = parseQuickGuideFromContent(guidePage.text);
      if (quickGuide.length) quest.quickGuide = quickGuide;
    }

    return quest;
  }

  private async getDBPageByTitle(title: string): Promise<typeof WikiPage.$inferSelect | undefined> {
    const db = this.databaseService.getDb();
    const rows = await db.select().from(WikiPage).where(eq(WikiPage.title, title)).limit(1);
    return rows?.[0];
  }
}
