import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync } from "fs";
import { safeWriteFileSync } from "../../utils/safe-write";
import { ALL_SKILL_RESOURCES } from "../../constants/rs3-paths";
import { SkillResource } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseSkillResourceFromContent } from "../../modules/extractors/skill-resources.extractor";
import { Rs3ItemsExtractor } from "./rs3-items.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/** RS3 counterpart of {@link SkillResourcesExtractor}. */
@Injectable()
export class Rs3SkillResourcesExtractor {
  private logger = new Logger(Rs3SkillResourcesExtractor.name);
  private cachedSkillResources: SkillResource[] | null = null;

  constructor(
    private readonly itemsExtractor: Rs3ItemsExtractor,
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllSkillResources(): Promise<SkillResource[]> {
    this.logger.log("Start: Extracting skill resources (RS3)");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.SKILL_RESOURCE);
    const length = pages.length;
    const skillResources: SkillResource[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Skill resources: ${i}/${length}`);
      }
      skillResources.push(...(await this.extractSkillResourcesFromPageId(page.id)));
    }

    skillResources.sort((a, b) => a.skill.localeCompare(b.skill) || a.name.localeCompare(b.name));
    if (skillResources.length) {
      await safeWriteFileSync(ALL_SKILL_RESOURCES, JSON.stringify(skillResources, null, 2));
    }

    this.logger.log("Done: Extracting skill resources (RS3)");
    return skillResources;
  }

  public getAllSkillResources(): SkillResource[] | null {
    if (!this.cachedSkillResources) {
      if (!existsSync(ALL_SKILL_RESOURCES)) {
        return null;
      }
      try {
        this.cachedSkillResources = JSON.parse(readFileSync(ALL_SKILL_RESOURCES, "utf8"));
      } catch (e) {
        this.logger.warn("all skill resources has invalid content", e);
      }
    }
    return this.cachedSkillResources;
  }

  private async extractSkillResourcesFromPageId(pageId: number): Promise<SkillResource[]> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return [];
    }
    return parseSkillResourceFromContent(page.text, page.title, page.aliases || [], (name) =>
      this.itemsExtractor.getItemByName(name),
    );
  }
}
