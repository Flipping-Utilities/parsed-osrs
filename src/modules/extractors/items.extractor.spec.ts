import parseInfo from 'infobox-parser';
import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '@/constants/test-pages';
import { parseItemFromWikiData, type WikiItem } from './items.extractor';

const parseFixtureInfo = (page: TestPage): WikiItem => {
  return parseInfo(
    page.text.replace(/\{\|/g, '{a|').replace(/\{\{sic\}\}/g, '')
  ).general;
};

describe('parseItemFromWikiData', () => {
  it('parses a single-variant non-tradeable item from real wiki data', () => {
    const page = loadTestPage(TestPages.Bucket15ths);
    const parsed = parseFixtureInfo(page);

    const items = parseItemFromWikiData(
      parsed,
      page.title,
      page.text,
      page.aliases,
      {}
    );

    expect(items).toHaveLength(1);
    expect(items[0]).toMatchObject({
      id: 3726,
      name: '1/5ths full bucket',
      examine:
        'This bucket is twenty percent full. It has a 5 painted on its side.',
      isMembers: true,
      isTradeable: false,
      isEquipable: false,
      isStackable: false,
      isOnGrandExchange: false,
      isAlchable: false,
      value: 1,
      weight: 0.001,
      drop: "You'll have to find another from within the building.",
      aliases: ['1-5ths full bucket'],
      limit: 0,
      isInMainGame: true,
    });
  });

  it('parses a tradeable and equipable GE item with a provided GE limit', () => {
    const page = loadTestPage(TestPages.ThirdAgeFellingAxe);
    const parsed = parseFixtureInfo(page);

    const items = parseItemFromWikiData(
      parsed,
      page.title,
      page.text,
      page.aliases,
      { '3rd age felling axe': 8 }
    );

    expect(items).toHaveLength(1);
    expect(items[0]).toMatchObject({
      id: 28226,
      name: '3rd age felling axe',
      examine: 'A beautifully crafted felling axe, shaped by ancient smiths.',
      isMembers: true,
      isTradeable: true,
      isEquipable: true,
      isStackable: false,
      isOnGrandExchange: true,
      isAlchable: false,
      value: 55000,
      weight: 1.814,
      aliases: [
        '3rd age 2h axe',
        '3a felling',
        'Third age felling axe',
        '3rd age felling',
        '2h 3rd age axe',
      ],
      limit: 8,
      isInMainGame: true,
    });
  });

  it('passes aliases and extracts values from another real single-variant item', () => {
    const page = loadTestPage(TestPages.AdamantSetLg);
    const parsed = parseFixtureInfo(page);

    const items = parseItemFromWikiData(
      parsed,
      page.title,
      page.text,
      page.aliases,
      { 'Adamant set (lg)': 70 }
    );

    expect(items).toHaveLength(1);
    expect(items[0]).toMatchObject({
      id: 13012,
      name: 'Adamant set (lg)',
      examine: 'A set containing a full helm, platebody, legs and kiteshield.',
      isMembers: false,
      isTradeable: true,
      isEquipable: false,
      isOnGrandExchange: true,
      value: 8000,
      weight: 6,
      aliases: [
        'Adamant set (lg',
        'Adamant armour set (lg)',
        'Adamant set lg',
        'Addy set',
        'Adamant lg',
        'Addamant plate',
      ],
      limit: 70,
    });
  });

  it('parses real multi-variant wiki data and links related variants', () => {
    const page = loadTestPage(TestPages.Mixture);
    const parsed = parseFixtureInfo(page);

    const items = parseItemFromWikiData(
      parsed,
      page.title,
      page.text,
      page.aliases,
      {}
    );

    expect(items).toHaveLength(3);

    const hot = items.find((item) => item.id === 5589);
    const warm = items.find((item) => item.id === 5590);
    const horrible = items.find((item) => item.id === 5591);

    expect(hot).toBeDefined();
    expect(warm).toBeDefined();
    expect(horrible).toBeDefined();

    expect(hot).toMatchObject({
      id: 5589,
      name: '??? mixture',
      examine:
        "A very hot vial of something or other. The label says 'Cupric Sulfate'.",
      isMembers: true,
      isTradeable: false,
      isEquipable: false,
      isStackable: false,
      value: 1,
      weight: 0.056,
      aliases: [
        '??? mixture (hot)',
        '??? mixture (warm)',
        '??? mixture (horrible)',
      ],
      relatedItems: [5590, 5591],
      limit: 0,
    });

    expect(warm).toMatchObject({
      id: 5590,
      name: '??? mixture',
      examine: "A very warm vial of something or other. It's a bit lumpy.",
      isMembers: true,
      isTradeable: false,
      isEquipable: false,
      isStackable: false,
      value: 1,
      weight: 0.056,
      aliases: [
        '??? mixture (hot)',
        '??? mixture (warm)',
        '??? mixture (horrible)',
      ],
      relatedItems: [5589, 5591],
      limit: 0,
    });

    expect(horrible).toMatchObject({
      id: 5591,
      name: '??? mixture',
      examine: 'It looks horrible. I think I messed something up.',
      isMembers: true,
      isTradeable: false,
      isEquipable: false,
      isStackable: false,
      value: 1,
      weight: 0.056,
      aliases: [
        '??? mixture (hot)',
        '??? mixture (warm)',
        '??? mixture (horrible)',
      ],
      relatedItems: [5589, 5590],
      limit: 0,
    });
  });
});
