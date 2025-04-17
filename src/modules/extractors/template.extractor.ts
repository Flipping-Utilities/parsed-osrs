import { Injectable, Logger } from '@nestjs/common';
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import * as wtf from 'wtf_wikipedia';

import path from 'path';
import { TEMPLATE_FOLDER } from '../../constants/paths';
import { PageListDumper } from '../dumpers';

interface Template {
  template: string;
  [property: string]: unknown;
}

@Injectable()
export class TemplateExtractor {
  private logger: Logger = new Logger(TemplateExtractor.name);
  constructor(private readonly pageListDumper: PageListDumper) {}

  public async extractAllTemplates() {
    this.logger.log('Start: extracting templates');
    const allPageList = await this.pageListDumper.getWikiPageListDB();
    const templateRecord: Record<string, Array<any>> = {};

    const l = allPageList.length;
    for (let i = 0; i < l; i++) {
      if (i % 1000 === 999) {
        this.logger.verbose(`${i + 1}/${l}`);
      }
      const page = allPageList[i];
      if (!page) {
        this.logger.warn('Could not find page with id', page.id);
        continue;
      }
      const meta = wtf(page.text);
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
        `/${template.replace(/[^a-z0-9]/gi, '_').toLowerCase()}.json`;
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
    this.logger.log('End: extracting templates');
  }
}
