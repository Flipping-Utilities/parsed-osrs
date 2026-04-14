import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import { parseShopFromContent } from './shops.extractor';

const KNOWN_ITEMS: Record<string, { id: number }> = {
  'Leather body': { id: 1129 },
  'Hardleather body': { id: 1131 },
  'Studded body': { id: 1133 },
  'Leather chaps': { id: 1095 },
  'Studded chaps': { id: 1097 },
  Coif: { id: 1169 },
  'Leather cowl': { id: 1167 },
  'Leather vambraces': { id: 1063 },
  'Pot of flour': { id: 1933 },
  'Raw beef': { id: 2132 },
  Cabbage: { id: 1965 },
  Banana: { id: 1963 },
  Redberries: { id: 1951 },
  Bread: { id: 2309 },
  'Chocolate bar': { id: 1973 },
  Cheese: { id: 1985 },
  Tomato: { id: 1982 },
  Potato: { id: 1942 },
};

describe('parseShopFromContent', () => {
  const aaronPage = loadTestPage(TestPages.AaronsArcheryAppendages);
  const unusedShopsPage = loadTestPage(TestPages.UnusedShops);

  const itemLookup = (name: string) => KNOWN_ITEMS[name] || null;

  it("parses Aaron's Archery Appendages using real fixture data", () => {
    const shop = parseShopFromContent(
      aaronPage.text,
      aaronPage.title,
      aaronPage.id,
      itemLookup
    );

    expect(shop).not.toBeNull();
    expect(shop!.name).toBe("Aaron's Archery Appendages.");
    expect(shop!.pageId).toBe(29644);
    expect(shop!.sellPercent).toBe(1);
    expect(shop!.buyPercent).toBe(0.5);
    expect(shop!.buyChangePercent).toBe(0.01);
    expect(shop!.inventory).toHaveLength(8);
    expect(shop!.inventory).toEqual([
      { itemId: 1129, baseQuantity: 10, restockTime: 50 },
      { itemId: 1131, baseQuantity: 10, restockTime: 60 },
      { itemId: 1133, baseQuantity: 10, restockTime: 70 },
      { itemId: 1095, baseQuantity: 20, restockTime: 50 },
      { itemId: 1097, baseQuantity: 15, restockTime: 80 },
      { itemId: 1169, baseQuantity: 10, restockTime: 50 },
      { itemId: 1167, baseQuantity: 10, restockTime: 70 },
      { itemId: 1063, baseQuantity: 10, restockTime: 150 },
    ]);
  });

  it('parses Unused shops with first table multipliers from real fixture data', () => {
    const shop = parseShopFromContent(
      unusedShopsPage.text,
      unusedShopsPage.title,
      unusedShopsPage.id,
      itemLookup
    );

    expect(shop).not.toBeNull();
    expect(shop!.name).toBe('Unused shops');
    expect(shop!.pageId).toBe(333174);
    expect(shop!.sellPercent).toBe(1);
    expect(shop!.buyPercent).toBe(0.7);
    expect(shop!.buyChangePercent).toBe(0.01);
    expect(shop!.inventory).toEqual([
      { itemId: 1933, baseQuantity: 3, restockTime: 100 },
      { itemId: 2132, baseQuantity: 1, restockTime: 100 },
      { itemId: 1965, baseQuantity: 3, restockTime: 100 },
      { itemId: 1963, baseQuantity: 3, restockTime: 100 },
      { itemId: 1951, baseQuantity: 1, restockTime: 100 },
      { itemId: 2309, baseQuantity: 0, restockTime: 100 },
      { itemId: 1973, baseQuantity: 1, restockTime: 95 },
      { itemId: 1985, baseQuantity: 3, restockTime: 100 },
      { itemId: 1982, baseQuantity: 3, restockTime: 100 },
      { itemId: 1942, baseQuantity: 1, restockTime: 100 },
    ]);
  });

  it('skips items that are not present in the lookup map', () => {
    const narrowLookup = (name: string) => {
      const knownSubset: Record<string, { id: number }> = {
        'Pot of flour': { id: 1933 },
        Cheese: { id: 1985 },
      };
      return knownSubset[name] || null;
    };

    const shop = parseShopFromContent(
      unusedShopsPage.text,
      unusedShopsPage.title,
      unusedShopsPage.id,
      narrowLookup
    );

    expect(shop).not.toBeNull();
    expect(shop!.inventory).toEqual([
      { itemId: 1933, baseQuantity: 3, restockTime: 100 },
      { itemId: 1985, baseQuantity: 3, restockTime: 100 },
    ]);
  });

  it('returns null for non-shop page', () => {
    const nonShopPage = loadTestPage(TestPages.StoneBowl);
    const shop = parseShopFromContent(
      nonShopPage.text,
      nonShopPage.title,
      nonShopPage.id,
      itemLookup
    );
    expect(shop).toBeNull();
  });

  it('parses Farming shops with hidebuy/hidestock/hiderestock format', () => {
    const farmingPage = loadTestPage(TestPages.FarmingShops);
    const farmingLookup = (name: string) => {
      const items: Record<string, { id: number }> = {
        'Plant cure': { id: 6036 },
        Compost: { id: 6032 },
        Rake: { id: 5341 },
        'Empty plant pot': { id: 5350 },
        'Watering can': { id: 5339 },
        'Gardening trowel': { id: 5325 },
        'Seed dibber': { id: 5343 },
      };
      return items[name] || null;
    };
    const shop = parseShopFromContent(
      farmingPage.text,
      farmingPage.title,
      farmingPage.id,
      farmingLookup
    );
    expect(shop).not.toBeNull();
    expect(shop!.name).toBe('Farming shops');
    expect(shop!.pageId).toBe(22523);
    expect(shop!.sellPercent).toBe(0);
    expect(shop!.buyPercent).toBe(0);
    expect(shop!.buyChangePercent).toBe(0);
    expect(shop!.inventory.length).toBeGreaterThan(0);
  });
});
