import { Injectable, Logger } from '@nestjs/common';
import { writeFileSync, existsSync, mkdirSync } from 'fs';
import * as wtf from 'wtf_wikipedia';

import { TEMPLATE_FOLDER } from '../../constants/paths';
import { PageContentDumper, PageListDumper } from '../dumpers';
import path from 'path';

interface Template {
  template: string;
  [property: string]: unknown;
}

@Injectable()
export class TemplateExtractor {
  private logger: Logger = new Logger(TemplateExtractor.name);
  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllTemplates() {
    const allPageList = this.pageListDumper.getWikiPageList();
    const templateRecord: Record<string, Array<any>> = {};

    const l = allPageList.length;
    for (let i = 0; i < l; i++) {
      if (i % 100 === 99) {
        this.logger.verbose(`${i + 1}/${l}`);
      }
      const pageMeta = allPageList[i];
      const page = this.pageContentDumper.getPageFromId(pageMeta.pageid);
      const meta = wtf(page.rawContent);
      const pageTemplates = meta
        .templates()
        .map((v) => v.json()) as Array<Template>;
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
      if (!path) {
        // @ts-ignore
        path = require('path');
      }
      const location =
        TEMPLATE_FOLDER +
        `/${template
          .replaceAll('.', '·')
          .replaceAll('\n', '')
          .replaceAll(':', '-')
          .replaceAll(' ', '_')
          .replaceAll('>', 'lt')
          .replaceAll('<', 'gt')
          .replaceAll('*', 'x')
          .replaceAll('#', '')}.json`;
      try {
        const dir = path.dirname(location);
        if (!existsSync(dir)) {
          mkdirSync(dir, { recursive: true });
        }

        writeFileSync(
          path.resolve(location),
          JSON.stringify(templateRecord[template], null, 2)
        );
      } catch (e) {
        this.logger.error(e, template, location);
      }
    });
  }
}
