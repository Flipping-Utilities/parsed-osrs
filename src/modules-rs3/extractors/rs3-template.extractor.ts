import { Injectable, Logger } from "@nestjs/common";
import { existsSync, mkdirSync, writeFileSync } from "fs";
import wtf from "wtf_wikipedia";
import path from "path";
import { TEMPLATE_FOLDER } from "../../constants/rs3-paths";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

interface Template {
  template: string;
  [property: string]: unknown;
}

/** RS3 counterpart of {@link TemplateExtractor}. */
@Injectable()
export class Rs3TemplateExtractor {
  private logger: Logger = new Logger(Rs3TemplateExtractor.name);
  constructor(private readonly pageListDumper: Rs3PageListDumper) {}

  public async extractAllTemplates() {
    this.logger.log("Start: extracting templates (RS3)");
    const allPageList = await this.pageListDumper.getWikiPageListDB();
    const templateRecord: Record<string, Array<any>> = {};

    const l = allPageList.length;
    for (let i = 0; i < l; i++) {
      if (i % 5000 === 4999) {
        this.logger.verbose(`${i + 1}/${l}`);
      }
      const page = allPageList[i];
      const meta = wtf(page.text!);
      const pageTemplates = meta.templates().map((v) => v.json()) as Array<Template>;
      pageTemplates
        .filter((t) => Object.keys(t).length > 1)
        .forEach((template) => {
          const templateName = template.template;
          if (!templateRecord[templateName]) {
            templateRecord[templateName] = [];
          }
          templateRecord[templateName].push(template);
        });
    }

    Object.keys(templateRecord).forEach((template) => {
      const location =
        TEMPLATE_FOLDER + `/${template.replace(/[^a-z0-9]/gi, "_").toLowerCase()}.json`;
      try {
        const dir = path.dirname(location);
        if (!existsSync(dir)) {
          mkdirSync(dir, { recursive: true });
        }
        writeFileSync(path.resolve(location), JSON.stringify(templateRecord[template]));
      } catch (e) {
        this.logger.error(e, template, location);
      }
    });
    this.logger.log("End: extracting templates (RS3)");
  }
}
