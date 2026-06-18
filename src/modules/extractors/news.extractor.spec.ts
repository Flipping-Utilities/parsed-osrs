import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import {
  parseNewsFromContent,
  parseUpdateTemplate,
  renderNewsBody,
} from './news.extractor';

describe('parseUpdateTemplate', () => {
  it('parses the {{Update}} parameters into a lower-cased key map', () => {
    const page = loadTestPage(TestPages.SuperStrengthBeerCheat);
    const params = parseUpdateTemplate(page.text);

    expect(params.date).toBe('25 January 2001');
    expect(params.category).toBe('Game');
    expect(params.link).toBe('no');
    expect(params.time).toBe('historical');
  });

  it('returns an empty object when no Update template is present', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    expect(parseUpdateTemplate(page.text)).toEqual({});
  });
});

describe('renderNewsBody', () => {
  it('emits markdown-style headings and preserves paragraph text', () => {
    const body = renderNewsBody(
      'Intro line.\n\n==Bank Tags==\nBank tags are great.\n\n===Details===\nHow they work.'
    );

    expect(body).toContain('Intro line.');
    expect(body).toContain('# Bank Tags');
    expect(body).toContain('## Details');
    expect(body).toContain('Bank tags are great.');
    expect(body).toContain('How they work.');
  });

  it('strips the Update template and magic words from the body', () => {
    const page = loadTestPage(TestPages.SuperStrengthBeerCheat);
    const body = renderNewsBody(page.text);

    expect(body).not.toContain('{{Update');
    expect(body).toContain('super strong');
  });
});

describe('parseNewsFromContent', () => {
  it('parses a newspost into a NewsArticle with metadata and body', () => {
    const page = loadTestPage(TestPages.SuperStrengthBeerCheat);
    const article = parseNewsFromContent(
      page.text,
      page.title,
      page.aliases,
      page.id
    );

    expect(article).not.toBeNull();
    expect(article!.pageId).toBe(47397);
    expect(article!.title).toBe("'Super strength Beer cheat' fixed");
    expect(article!.date).toBe('25 January 2001');
    expect(article!.dateIso).toContain('2001-01-25');
    expect(article!.category).toBe('game');
    expect(article!.url).toBe('');
    expect(article!.wikiUrl).toBe(
      'https://oldschool.runescape.wiki/w/?curid=47397'
    );
    expect(article!.body).toContain('super strong');
  });

  it('returns null for a page with no Update template', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    expect(
      parseNewsFromContent(page.text, page.title, page.aliases, page.id)
    ).toBeNull();
  });
});
