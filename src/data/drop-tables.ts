import type { DropTable } from '../types/monster';

function parseRate(rate: string): number {
  const parts = rate.split('/');
  if (parts.length === 2) return Number(parts[0]) / Number(parts[1]);
  return Number(rate) || 0;
}

function parseRolls(rolls: string | undefined): number {
  if (!rolls) return 1;
  const n = Number(rolls);
  return Number.isFinite(n) && n > 0 ? n : 1;
}

function formatRarity(probability: number): string {
  if (probability <= 0) return 'Never';
  return '1/' + (1 / probability).toFixed(1);
}

interface ExpandedDrop {
  name: string;
  quantity: number | string;
  rarity: string;
}

function rdtItems(
  rdtRate: number,
  gdtRate: number,
  chaosTalisman: boolean,
  natureTalisman: boolean
): ExpandedDrop[] {
  const r = rdtRate;
  const g = gdtRate;
  const items: ExpandedDrop[] = [
    { name: 'Coins', quantity: 3000, rarity: formatRarity(r * 21 / 128) },
    { name: 'Uncut sapphire', quantity: 1, rarity: formatRarity(r * 20 / 128 * 32 / 128 + g * 32 / 128) },
    { name: 'Loop half of key', quantity: 1, rarity: formatRarity(r * 20 / 128 + r * 20 / 128 * 1 / 128 + g * 1 / 128) },
    { name: 'Tooth half of key', quantity: 1, rarity: formatRarity(r * 20 / 128 + r * 20 / 128 * 1 / 128 + g * 1 / 128) },
    { name: 'Uncut emerald', quantity: 1, rarity: formatRarity(r * 20 / 128 * 16 / 128 + g * 16 / 128) },
    { name: 'Uncut ruby', quantity: 1, rarity: formatRarity(r * 20 / 128 * 8 / 128 + g * 8 / 128) },
    { name: 'Runite bar', quantity: 1, rarity: formatRarity(r * 5 / 128) },
    { name: 'Nature rune', quantity: 67, rarity: formatRarity(r * 3 / 128) },
    { name: 'Rune 2h sword', quantity: 1, rarity: formatRarity(r * 3 / 128) },
    { name: 'Rune battleaxe', quantity: 1, rarity: formatRarity(r * 3 / 128) },
    { name: 'Law rune', quantity: 45, rarity: formatRarity(r * 2 / 128) },
    { name: 'Death rune', quantity: 45, rarity: formatRarity(r * 2 / 128) },
    { name: 'Steel arrow', quantity: 150, rarity: formatRarity(r * 2 / 128) },
    { name: 'Rune arrow', quantity: 42, rarity: formatRarity(r * 2 / 128) },
    { name: 'Adamant javelin', quantity: 20, rarity: formatRarity(r * 2 / 128) },
    { name: 'Rune sq shield', quantity: 1, rarity: formatRarity(r * 2 / 128) },
    { name: 'Dragonstone', quantity: 1, rarity: formatRarity(r * 2 / 128) },
    { name: 'Silver ore', quantity: '100 (noted)', rarity: formatRarity(r * 2 / 128) },
    { name: 'Uncut diamond', quantity: 1, rarity: formatRarity(r * 20 / 128 * 2 / 128 + g * 2 / 128) },
    { name: 'Rune kiteshield', quantity: 1, rarity: formatRarity(r * 1 / 128) },
    { name: 'Dragon med helm', quantity: 1, rarity: formatRarity(r * 1 / 128) },
    { name: 'Rune spear', quantity: 1, rarity: formatRarity(r * 20 / 128 * 1 / 128 * 8 / 128 + r * 15 / 128 * 8 / 128 + g * 1 / 128 * 8 / 128) },
    { name: 'Rune javelin', quantity: 5, rarity: formatRarity(r * 20 / 128 * 1 / 128 + g * 1 / 128) },
    { name: 'Shield left half', quantity: 1, rarity: formatRarity(r * 20 / 128 * 1 / 128 * 4 / 128 + r * 15 / 128 * 4 / 128 + g * 1 / 128 * 4 / 128) },
    { name: 'Dragon spear', quantity: 1, rarity: formatRarity(r * 20 / 128 * 1 / 128 * 3 / 128 + r * 15 / 128 * 3 / 128 + g * 1 / 128 * 3 / 128) },
  ];

  const talismanRarity = r * 20 / 128 * 3 / 128 + g * 3 / 128;
  if (chaosTalisman) {
    items.push({ name: 'Chaos talisman', quantity: 1, rarity: formatRarity(talismanRarity) });
  }
  if (natureTalisman) {
    items.push({ name: 'Nature talisman', quantity: 1, rarity: formatRarity(talismanRarity) });
  }
  if (!chaosTalisman && !natureTalisman) {
    items.push({ name: 'Unknown talisman', quantity: 1, rarity: formatRarity(talismanRarity) });
  }

  return items;
}

function gdtItems(
  rate: number,
  chaosTalisman: boolean,
  natureTalisman: boolean
): ExpandedDrop[] {
  const items: ExpandedDrop[] = [
    { name: 'Uncut sapphire', quantity: 1, rarity: formatRarity(rate * 32 / 128) },
    { name: 'Uncut emerald', quantity: 1, rarity: formatRarity(rate * 16 / 128) },
    { name: 'Uncut ruby', quantity: 1, rarity: formatRarity(rate * 8 / 128) },
    { name: 'Uncut diamond', quantity: 1, rarity: formatRarity(rate * 2 / 128) },
    { name: 'Rune javelin', quantity: 5, rarity: formatRarity(rate * 1 / 128) },
    { name: 'Loop half of key', quantity: 1, rarity: formatRarity(rate * 1 / 128) },
    { name: 'Tooth half of key', quantity: 1, rarity: formatRarity(rate * 1 / 128) },
    { name: 'Rune spear', quantity: 1, rarity: formatRarity(rate * 1 / 128 * 8 / 128) },
    { name: 'Shield left half', quantity: 1, rarity: formatRarity(rate * 1 / 128 * 4 / 128) },
    { name: 'Dragon spear', quantity: 1, rarity: formatRarity(rate * 1 / 128 * 3 / 128) },
  ];

  const talismanRarity = rate * 3 / 128;
  if (chaosTalisman) {
    items.push({ name: 'Chaos talisman', quantity: 1, rarity: formatRarity(talismanRarity) });
  }
  if (natureTalisman) {
    items.push({ name: 'Nature talisman', quantity: 1, rarity: formatRarity(talismanRarity) });
  }
  if (!chaosTalisman && !natureTalisman) {
    items.push({ name: 'Unknown talisman', quantity: 1, rarity: formatRarity(talismanRarity) });
  }

  return items;
}

const HERB_TABLE = [
  { name: 'Grimy guam leaf', quantity: 1, weight: 32 },
  { name: 'Grimy marrentill', quantity: 1, weight: 24 },
  { name: 'Grimy tarromin', quantity: 1, weight: 18 },
  { name: 'Grimy harralander', quantity: 1, weight: 14 },
  { name: 'Grimy ranarr weed', quantity: 1, weight: 11 },
  { name: 'Grimy irit leaf', quantity: 1, weight: 8 },
  { name: 'Grimy avantoe', quantity: 1, weight: 6 },
  { name: 'Grimy kwuarm', quantity: 1, weight: 5 },
  { name: 'Grimy cadantine', quantity: 1, weight: 4 },
  { name: 'Grimy lantadyme', quantity: 1, weight: 3 },
  { name: 'Grimy dwarf weed', quantity: 1, weight: 3 },
] as const;

const SEED_TABLE = [
  { name: 'Toadflax seed', quantity: 1, weight: 216 },
  { name: 'Irit seed', quantity: 1, weight: 148 },
  { name: 'Belladonna seed', quantity: 1, weight: 143 },
  { name: 'Poison ivy seed', quantity: 1, weight: 103 },
  { name: 'Avantoe seed', quantity: 1, weight: 101 },
  { name: 'Cactus seed', quantity: 1, weight: 96 },
  { name: 'Potato cactus seed', quantity: 1, weight: 70 },
  { name: 'Kwuarm seed', quantity: 1, weight: 69 },
  { name: 'Snapdragon seed', quantity: 1, weight: 46 },
  { name: 'Cadantine seed', quantity: 1, weight: 32 },
  { name: 'Lantadyme seed', quantity: 1, weight: 23 },
  { name: 'Snape grass seed', quantity: 3, weight: 20 },
  { name: 'Dwarf weed seed', quantity: 1, weight: 14 },
  { name: 'Torstol seed', quantity: 1, weight: 9 },
] as const;

const SEED_TOTAL_WEIGHT = SEED_TABLE.reduce((sum, s) => sum + s.weight, 0);

function herbItems(herbRate: number, quantity?: string): ExpandedDrop[] {
  return HERB_TABLE.map((herb) => ({
    name: herb.name,
    quantity: quantity ?? herb.quantity,
    rarity: formatRarity(herbRate * herb.weight / 128),
  }));
}

function seedItems(seedRate: number): ExpandedDrop[] {
  return SEED_TABLE.map((seed) => ({
    name: seed.name,
    quantity: seed.quantity,
    rarity: formatRarity(seedRate * seed.weight / SEED_TOTAL_WEIGHT),
  }));
}

export function expandDropTables(
  dropTables: DropTable[],
  herbQuantity?: string
): ExpandedDrop[] {
  const results: ExpandedDrop[] = [];

  const rdt = dropTables.find((t) => t.type === 'rare_drop_table');
  const gdt = dropTables.find((t) => t.type === 'gem_drop_table');
  const herb = dropTables.find((t) => t.type === 'herb_drop_table');
  const seed = dropTables.find((t) => t.type === 'rare_seed_drop_table');

  const chaos = rdt?.chaosTalisman || gdt?.chaosTalisman;
  const nature = rdt?.natureTalisman || gdt?.natureTalisman;

  if (rdt) {
    const rdtRolls = parseRolls(rdt.rolls);
    const rdtRate = parseRate(rdt.rarity ?? '') * rdtRolls;
    const gdtRolls = gdt ? parseRolls(gdt.rolls) : 0;
    const gdtRate = gdt ? parseRate(gdt.rarity ?? '') * gdtRolls : 0;
    results.push(...rdtItems(rdtRate, gdtRate, !!chaos, !!nature));
  } else if (gdt) {
    const gdtRolls = parseRolls(gdt.rolls);
    const gdtRate = parseRate(gdt.rarity ?? '') * gdtRolls;
    results.push(...gdtItems(gdtRate, !!chaos, !!nature));
  }

  if (herb) {
    const herbRolls = parseRolls(herb.rolls);
    const herbRate = parseRate(herb.rarity ?? '') * herbRolls;
    results.push(...herbItems(herbRate, herbQuantity));
  }

  if (seed) {
    const seedRolls = parseRolls(seed.rolls);
    const seedRate = parseRate(seed.rarity ?? '') * seedRolls;
    results.push(...seedItems(seedRate));
  }

  return results;
}
