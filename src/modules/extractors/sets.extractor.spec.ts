import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import { parseSetFromContent } from './sets.extractor';

describe('parseSetFromContent', () => {
  const itemsByName: Record<string, { id: number }> = {
    'Adamant full helm': { id: 1185 },
    'Adamant platebody': { id: 1123 },
    'Adamant platelegs': { id: 1073 },
    'Adamant kiteshield': { id: 1201 },
    'Adamant set (lg)': { id: 13012 },
    'Adamant gold-trimmed set (lg)': { id: 13020 },
    'Adamant gold-trimmed set (sk)': { id: 13022 },
    'Adamant full helm (g)': { id: 10297 },
    'Adamant platebody (g)': { id: 10294 },
    'Adamant platelegs (g)': { id: 10295 },
    'Adamant plateskirt (g)': { id: 10296 },
    'Adamant kiteshield (g)': { id: 10298 },
  };

  const itemLookup = (name: string) => itemsByName[name] ?? null;

  it('parses set with multiple CostLine components', () => {
    const page = loadTestPage(TestPages.AdamantSetLg);

    const set = parseSetFromContent(page.text, page.title, itemLookup);

    expect(set).not.toBeNull();
    expect(set!.name).toBe('Adamant set (lg)');
    expect(set!.id).toBe(13012);
    expect(set!.componentIds).toEqual([1185, 1123, 1073, 1201]);
  });

  it('parses gold-trimmed set with multiple CostLine components', () => {
    const page = loadTestPage(TestPages.AdamantGoldTrimmedSetLg);

    const set = parseSetFromContent(page.text, page.title, itemLookup);

    expect(set).not.toBeNull();
    expect(set!.name).toBe('Adamant gold-trimmed set (lg)');
    expect(set!.id).toBe(13020);
    expect(set!.componentIds).toEqual([10297, 10294, 10295, 10298]);
  });

  it('parses Rune armour set (lg) with expected components', () => {
    const page = loadTestPage(TestPages.RuneArmourSetLg);

    const runeItemsByName: Record<string, { id: number }> = {
      'Rune full helm': { id: 1163 },
      'Rune platebody': { id: 1127 },
      'Rune platelegs': { id: 1079 },
      'Rune kiteshield': { id: 1201 },
      'Rune armour set (lg)': { id: 13024 },
    };
    const runeLookup = (name: string) => runeItemsByName[name] ?? null;

    const set = parseSetFromContent(page.text, page.title, runeLookup);

    expect(set).not.toBeNull();
    expect(set!.name).toBe('Rune armour set (lg)');
    expect(set!.id).toBe(13024);
    expect(set!.componentIds).toEqual([1163, 1127, 1079, 1201]);
  });

  it('returns null for page with no CostLine templates', () => {
    const nonSetPage = loadTestPage(TestPages.StoneBowl);
    const set = parseSetFromContent(
      nonSetPage.text,
      nonSetPage.title,
      itemLookup
    );
    expect(set).toBeNull();
  });
});
