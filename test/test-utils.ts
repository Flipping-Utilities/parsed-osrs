import { readFileSync } from 'fs';
import path from 'path';

export interface TestPage {
  id: number;
  title: string;
  text: string;
  html: string;
  aliases: string[];
}

const pagesDir = path.resolve(__dirname, 'pages');

export function loadTestPage(pageId: number): TestPage {
  const filePath = path.join(pagesDir, `${pageId}.json`);
  return JSON.parse(readFileSync(filePath, 'utf8')) as TestPage;
}
