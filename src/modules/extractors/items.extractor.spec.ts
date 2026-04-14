import { parseWikitext } from '../../utils/wikitext-parser';
import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import {
  parseEquipmentStats,
  parseItemFromWikiData,
  extractImagesFromHtml,
} from './items.extractor';

const parseFixtureInfo = (page: TestPage): Record<string, string> => {
  const parsed = parseWikitext(page.text);
  return parsed.getInfobox('item') ?? {};
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
      equipmentStats: {
        attackStab: -3,
        attackSlash: 60,
        attackCrush: 51,
        attackMagic: 0,
        attackRanged: 0,
        defendStab: 0,
        defendSlash: 1,
        defendCrush: 0,
        defendMagic: 0,
        defendRanged: 0,
        strength: 67,
        rangedStrength: 0,
        magicDamage: 0,
        prayer: 0,
        slot: '2h',
        speed: 7,
        attackRange: 1,
        combatStyle: 'Axe',
      },
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

  it('does not include equipmentStats for non-equipable items', () => {
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
    expect(items[0].equipmentStats).toBeUndefined();
  });
});

describe('parseEquipmentStats', () => {
  it('extracts weapon stats from Abyssal whip', () => {
    const page = loadTestPage(TestPages.AbyssalWhip);

    const stats = parseEquipmentStats(page.text);

    expect(stats).toMatchObject({
      attackStab: 0,
      attackSlash: 82,
      attackCrush: 0,
      attackMagic: 0,
      attackRanged: 0,
      defendStab: 0,
      defendSlash: 0,
      defendCrush: 0,
      defendMagic: 0,
      defendRanged: 0,
      strength: 82,
      rangedStrength: 0,
      magicDamage: 0,
      prayer: 0,
      slot: 'weapon',
      speed: 4,
      attackRange: 1,
      combatStyle: 'Whip',
    });
  });

  it('extracts armor stats from Bandos chestplate with missing weapon fields', () => {
    const page = loadTestPage(TestPages.BandosChestplate);

    const stats = parseEquipmentStats(page.text);

    expect(stats).toMatchObject({
      attackStab: 0,
      attackSlash: 0,
      attackCrush: 0,
      attackMagic: -15,
      attackRanged: -10,
      defendStab: 98,
      defendSlash: 93,
      defendCrush: 105,
      defendMagic: -6,
      defendRanged: 133,
      strength: 4,
      rangedStrength: 0,
      magicDamage: 0,
      prayer: 1,
      slot: 'body',
      speed: 0,
      attackRange: 0,
      combatStyle: '',
    });
  });

  it('extracts magic gear stats from Ancestral hat with magicDamage', () => {
    const page = loadTestPage(TestPages.AncestralHat);

    const stats = parseEquipmentStats(page.text);

    expect(stats).toMatchObject({
      attackStab: 0,
      attackSlash: 0,
      attackCrush: 0,
      attackMagic: 8,
      attackRanged: -2,
      defendStab: 12,
      defendSlash: 11,
      defendCrush: 13,
      defendMagic: 5,
      defendRanged: 0,
      strength: 0,
      rangedStrength: 0,
      magicDamage: 3,
      prayer: 0,
      slot: 'head',
    });
  });

  it('returns null when page has no combat stats section', () => {
    const page = loadTestPage(TestPages.Bucket15ths);

    const stats = parseEquipmentStats(page.text);

    expect(stats).toBeNull();
  });
});

describe('parseItemFromWikiData with equipmentStats', () => {
  it('includes equipmentStats for Abyssal whip', () => {
    const page = loadTestPage(TestPages.AbyssalWhip);
    const parsed = parseFixtureInfo(page);

    const items = parseItemFromWikiData(
      parsed,
      page.title,
      page.text,
      page.aliases,
      {}
    );

    expect(items).toHaveLength(1);
    expect(items[0].isEquipable).toBe(true);
    expect(items[0].equipmentStats).toBeDefined();
    expect(items[0].equipmentStats!.slot).toBe('weapon');
    expect(items[0].equipmentStats!.strength).toBe(82);
  });

  it('includes equipmentStats for Bandos chestplate with defaults for missing weapon fields', () => {
    const page = loadTestPage(TestPages.BandosChestplate);
    const parsed = parseFixtureInfo(page);

    const items = parseItemFromWikiData(
      parsed,
      page.title,
      page.text,
      page.aliases,
      {}
    );

    expect(items).toHaveLength(1);
    expect(items[0].isEquipable).toBe(true);
    expect(items[0].equipmentStats).toBeDefined();
    expect(items[0].equipmentStats!.slot).toBe('body');
    expect(items[0].equipmentStats!.defendCrush).toBe(105);
    expect(items[0].equipmentStats!.speed).toBe(0);
    expect(items[0].equipmentStats!.combatStyle).toBe('');
  });

  it('includes equipmentStats for Ancestral hat with magicDamage bonus', () => {
    const page = loadTestPage(TestPages.AncestralHat);
    const parsed = parseFixtureInfo(page);

    const items = parseItemFromWikiData(
      parsed,
      page.title,
      page.text,
      page.aliases,
      {}
    );

    expect(items).toHaveLength(1);
    expect(items[0].isEquipable).toBe(true);
    expect(items[0].equipmentStats).toBeDefined();
    expect(items[0].equipmentStats!.slot).toBe('head');
    expect(items[0].equipmentStats!.magicDamage).toBe(3);
    expect(items[0].equipmentStats!.attackMagic).toBe(8);
  });
});

describe('extractImagesFromHtml', () => {
  it('extracts image from a single-variant infobox', () => {
    const html = `
      <table class="infobox-item">
        <tr><th>Members</th><td>Yes</td></tr>
        <tr><td colspan="2"><img src="/images/Bronze_sword.png" /></td></tr>
        <tr><th>ID</th><td>1321</td></tr>
      </table>
    `;

    const images = extractImagesFromHtml(html);

    expect(images.has(1321)).toBe(true);
    expect(images.get(1321)).toBe('File:Bronze_sword.png');
  });

  it('extracts images per variant in a multi-variant infobox', () => {
    const html = `
      <table class="infobox-item">
        <tr><td colspan="2"><a href="/w/Ahrim%27s_hood"><img src="/images/Ahrim%27s_hood_equipped_male.png" /></a></td></tr>
        <tr><th>ID</th><td>4708</td></tr>
        <tr><td colspan="2"><a href="/w/Ahrim%27s_hood_0"><img src="/images/Ahrim%27s_hood_0.png" /></a></td></tr>
        <tr><th>ID</th><td>4860</td></tr>
        <tr><td colspan="2"><a href="/w/Ahrim%27s_hood_100"><img src="/images/Ahrim%27s_hood_100.png" /></a></td></tr>
        <tr><th>ID</th><td>4856</td></tr>
      </table>
    `;

    const images = extractImagesFromHtml(html);

    expect(images.size).toBe(3);
    expect(images.get(4708)).toBe("File:Ahrim's_hood_equipped_male.png");
    expect(images.get(4860)).toBe("File:Ahrim's_hood_0.png");
    expect(images.get(4856)).toBe("File:Ahrim's_hood_100.png");
  });

  it('handles ID rows with comma-separated values', () => {
    const html = `
      <table class="infobox-item">
        <tr><td colspan="2"><img src="/images/Amulet_of_glory.png" /></td></tr>
        <tr><th>ID</th><td>1704, 1706</td></tr>
      </table>
    `;

    const images = extractImagesFromHtml(html);

    expect(images.has(1704)).toBe(true);
    expect(images.get(1704)).toBe('File:Amulet_of_glory.png');
  });

  it('returns empty map when html is empty', () => {
    const images = extractImagesFromHtml('');
    expect(images.size).toBe(0);
  });

  it('returns empty map when no img elements exist', () => {
    const html = `<table class="infobox-item"><tr><th>ID</th><td>1321</td></tr></table>`;
    const images = extractImagesFromHtml(html);
    expect(images.size).toBe(0);
  });
});
