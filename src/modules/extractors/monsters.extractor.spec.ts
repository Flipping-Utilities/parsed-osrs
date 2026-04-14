import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import { parseMonsterFromContent } from './monsters.extractor';

describe('parseMonsterFromContent', () => {
  const itemLookup = (name: string) => {
    const items: Record<string, { id: number }> = {
      Bones: { id: 526 },
    };
    return items[name] || null;
  };

  it('parses A Doubt with id and Bones drop', () => {
    const page = loadTestPage(TestPages.ADoubt);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.id).toBe(3477);
    expect(monster!.name).toBe('A Doubt');
    expect(monster!.drops).toHaveLength(1);
    expect(monster!.drops[0]).toEqual({
      name: 'Bones',
      quantity: '1',
      rarity: 'Always',
      itemId: 526,
    });
  });

  it('uses the first id from comma-separated ids on Aberrant spectre', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.id).toBe(2);
  });

  it('extracts examine text from wiki markup', () => {
    const page = loadTestPage(TestPages.AbhorrentSpectre);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.examine).toBe(
      "I'd smell better after completing 3145 laps of an agility course dressed as a monkey."
    );
  });

  it('passes through aliases from fixture data', () => {
    const page = loadTestPage(TestPages.ADoubt);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.aliases).toEqual(['Doubts', 'Doubt', 'A doubt']);
  });

  it('parses multiple drops from Aberrant spectre', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.drops.length).toBeGreaterThan(5);
    expect(monster!.drops).toContainEqual({
      name: 'Rune full helm',
      quantity: '1',
      rarity: '1/128',
      itemId: null,
    });
    expect(monster!.drops).toContainEqual({
      name: 'Lava battlestaff',
      quantity: '1',
      rarity: '1/128',
      itemId: null,
    });
    expect(monster!.drops).toContainEqual({
      name: 'Steel axe',
      quantity: '1',
      rarity: '3/128',
      itemId: null,
    });
  });

  it('sets itemId to null for drops not found by item lookup', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.drops).toContainEqual({
      name: 'Steel axe',
      quantity: '1',
      rarity: '3/128',
      itemId: null,
    });
  });

  it('extracts dropTables from Aberrant spectre (gem, herb, seed)', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.dropTables).toHaveLength(3);
    expect(monster!.dropTables).toContainEqual({
      type: 'gem_drop_table',
      rarity: '5/128',
      chaosTalisman: true,
      natureTalisman: true,
    });
    expect(monster!.dropTables).toContainEqual({
      type: 'herb_drop_table',
      rarity: '78/128',
    });
    expect(monster!.dropTables).toContainEqual({
      type: 'rare_seed_drop_table',
      rarity: '19/128',
    });
  });

  it('extracts rare_drop_table and gem_drop_table from Fire Giant', () => {
    const page = loadTestPage(TestPages.FireGiant);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.id).toBe(2075);
    expect(monster!.name).toBe('Fire giant');
    expect(monster!.dropTables).toHaveLength(3);
    expect(monster!.dropTables).toContainEqual({
      type: 'rare_drop_table',
      rarity: '1/128',
      chaosTalisman: true,
      natureTalisman: true,
    });
    expect(monster!.dropTables).toContainEqual({
      type: 'gem_drop_table',
      rarity: '11/128',
      chaosTalisman: true,
      natureTalisman: true,
    });
    expect(monster!.dropTables).toContainEqual({
      type: 'herb_drop_table',
      rarity: '19/128',
    });
  });

  it('expands Fire Giant RDT items into drops with computed rarities', () => {
    const page = loadTestPage(TestPages.FireGiant);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.drops).toContainEqual({
      name: 'Rune kiteshield',
      quantity: '1',
      rarity: '1/16384.0',
      itemId: null,
    });
    expect(monster!.drops).toContainEqual({
      name: 'Dragon med helm',
      quantity: '1',
      rarity: '1/16384.0',
      itemId: null,
    });
    expect(monster!.drops).toContainEqual({
      name: 'Grimy guam leaf',
      quantity: '1',
      rarity: '1/26.9',
      itemId: null,
    });
  });

  it('expands Aberrant Spectre GDT, herb, and seed items into drops', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.drops).toContainEqual({
      name: 'Uncut sapphire',
      quantity: '1',
      rarity: '1/102.4',
      itemId: null,
    });
    expect(monster!.drops).toContainEqual({
      name: 'Grimy guam leaf',
      quantity: '1-3',
      rarity: '1/6.6',
      itemId: null,
    });
    expect(monster!.drops).toContainEqual({
      name: 'Toadflax seed',
      quantity: '1',
      rarity: '1/34.0',
      itemId: null,
    });
  });

  it('returns null when page has no Monster ID', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    const monster = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monster).toBeNull();
  });
});
