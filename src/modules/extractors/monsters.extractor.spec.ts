import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '@/constants/test-pages';
import { parseMonsterFromHtml } from './monsters.extractor';

describe('parseMonsterFromHtml', () => {
  const itemLookup = (name: string) => {
    const items: Record<string, { id: number }> = {
      Bones: { id: 526 },
    };
    return items[name] || null;
  };

  it('parses A Doubt with id and Bones drop', () => {
    const page = loadTestPage(TestPages.ADoubt);
    const monster = parseMonsterFromHtml(
      page.html,
      page.title,
      page.text,
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
    const monster = parseMonsterFromHtml(
      page.html,
      page.title,
      page.text,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.id).toBe(2);
  });

  it('extracts examine text from wiki markup', () => {
    const page = loadTestPage(TestPages.AbhorrentSpectre);
    const monster = parseMonsterFromHtml(
      page.html,
      page.title,
      page.text,
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
    const monster = parseMonsterFromHtml(
      page.html,
      page.title,
      page.text,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.aliases).toEqual(['Doubts', 'Doubt', 'A doubt']);
  });

  it('parses multiple drops and their real values from Aberrant spectre', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monster = parseMonsterFromHtml(
      page.html,
      page.title,
      page.text,
      page.aliases,
      itemLookup
    );

    expect(monster).not.toBeNull();
    expect(monster!.drops.length).toBeGreaterThan(20);
    expect(monster!.drops).toContainEqual({
      name: 'Rune full helm',
      quantity: '1',
      rarity: '1/128',
      itemId: null,
    });
    expect(monster!.drops).toContainEqual({
      name: 'Grimy guam leaf',
      quantity: '1–3',
      rarity: '1/6.6',
      itemId: null,
    });
    expect(monster!.drops).toContainEqual({
      name: 'Lava battlestaff',
      quantity: '1',
      rarity: '1/128',
      itemId: null,
    });
  });

  it('sets itemId to null for drops not found by item lookup', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monster = parseMonsterFromHtml(
      page.html,
      page.title,
      page.text,
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

  it('returns null when page has no Monster ID', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    const monster = parseMonsterFromHtml(
      page.html,
      page.title,
      page.text,
      page.aliases,
      itemLookup
    );

    expect(monster).toBeNull();
  });
});
