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
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters).toHaveLength(1);
    expect(monsters[0].id).toBe(3477);
    expect(monsters[0].name).toBe('A Doubt');
    expect(monsters[0].drops).toHaveLength(1);
    expect(monsters[0].drops[0]).toEqual({
      name: 'Bones',
      quantity: '1',
      rarity: 'Always',
      itemId: 526,
    });
  });

  it('uses the first id from comma-separated ids on Aberrant spectre', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters).toHaveLength(1);
    expect(monsters[0].id).toBe(2);
  });

  it('extracts examine text from wiki markup', () => {
    const page = loadTestPage(TestPages.AbhorrentSpectre);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters).toHaveLength(1);
    expect(monsters[0].examine).toBe(
      "I'd smell better after completing 3145 laps of an agility course dressed as a monkey."
    );
  });

  it('passes through aliases from fixture data', () => {
    const page = loadTestPage(TestPages.ADoubt);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters).toHaveLength(1);
    expect(monsters[0].aliases).toEqual(['Doubts', 'Doubt', 'A doubt']);
  });

  it('parses multiple drops from Aberrant spectre', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters).toHaveLength(1);
    expect(monsters[0].drops.length).toBeGreaterThan(5);
    expect(monsters[0].drops).toContainEqual({
      name: 'Rune full helm',
      quantity: '1',
      rarity: '1/128',
      itemId: null,
    });
    expect(monsters[0].drops).toContainEqual({
      name: 'Lava battlestaff',
      quantity: '1',
      rarity: '1/128',
      itemId: null,
    });
    expect(monsters[0].drops).toContainEqual({
      name: 'Steel axe',
      quantity: '1',
      rarity: '3/128',
      itemId: null,
    });
  });

  it('sets itemId to null for drops not found by item lookup', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters).toHaveLength(1);
    expect(monsters[0].drops).toContainEqual({
      name: 'Steel axe',
      quantity: '1',
      rarity: '3/128',
      itemId: null,
    });
  });

  it('extracts dropTables from Aberrant spectre (gem, herb, seed)', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters).toHaveLength(1);
    expect(monsters[0].dropTables).toHaveLength(3);
    expect(monsters[0].dropTables).toContainEqual({
      type: 'gem_drop_table',
      rarity: '5/128',
      chaosTalisman: true,
      natureTalisman: true,
    });
    expect(monsters[0].dropTables).toContainEqual({
      type: 'herb_drop_table',
      rarity: '78/128',
    });
    expect(monsters[0].dropTables).toContainEqual({
      type: 'rare_seed_drop_table',
      rarity: '19/128',
    });
  });

  it('extracts rare_drop_table and gem_drop_table from Fire Giant', () => {
    const page = loadTestPage(TestPages.FireGiant);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters.length).toBeGreaterThan(0);
    expect(monsters[0].id).toBe(2075);
    expect(monsters[0].name).toBe('Fire giant');
    expect(monsters[0].dropTables).toHaveLength(3);
    expect(monsters[0].dropTables).toContainEqual({
      type: 'rare_drop_table',
      rarity: '1/128',
      chaosTalisman: true,
      natureTalisman: true,
    });
    expect(monsters[0].dropTables).toContainEqual({
      type: 'gem_drop_table',
      rarity: '11/128',
      chaosTalisman: true,
      natureTalisman: true,
    });
    expect(monsters[0].dropTables).toContainEqual({
      type: 'herb_drop_table',
      rarity: '19/128',
    });
  });

  it('expands Fire Giant RDT items into drops with computed rarities', () => {
    const page = loadTestPage(TestPages.FireGiant);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters.length).toBeGreaterThan(0);
    expect(monsters[0].drops).toContainEqual({
      name: 'Rune kiteshield',
      quantity: '1',
      rarity: '1/16384.0',
      itemId: null,
    });
    expect(monsters[0].drops).toContainEqual({
      name: 'Dragon med helm',
      quantity: '1',
      rarity: '1/16384.0',
      itemId: null,
    });
    expect(monsters[0].drops).toContainEqual({
      name: 'Grimy guam leaf',
      quantity: '1',
      rarity: '1/26.9',
      itemId: null,
    });
  });

  it('expands Aberrant Spectre GDT, herb, and seed items into drops', () => {
    const page = loadTestPage(TestPages.AberrantSpectre);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters).toHaveLength(1);
    expect(monsters[0].drops).toContainEqual({
      name: 'Uncut sapphire',
      quantity: '1',
      rarity: '1/102.4',
      itemId: null,
    });
    expect(monsters[0].drops).toContainEqual({
      name: 'Grimy guam leaf',
      quantity: '1-3',
      rarity: '1/6.6',
      itemId: null,
    });
    expect(monsters[0].drops).toContainEqual({
      name: 'Toadflax seed',
      quantity: '1',
      rarity: '1/34.0',
      itemId: null,
    });
  });

  it('returns empty array when page has no Monster ID', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    const monsters = parseMonsterFromContent(
      page.text,
      page.title,
      page.aliases,
      itemLookup
    );

    expect(monsters).toHaveLength(0);
  });

  describe('combat stats, slayer data, and immunities', () => {
    it('extracts all combat stats from Aberrant Spectre', () => {
      const page = loadTestPage(TestPages.AberrantSpectre);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(1);
      expect(monsters[0].combatLevel).toBe(96);
      expect(monsters[0].hitpoints).toBe(90);
      expect(monsters[0].attackLevel).toBe(1);
      expect(monsters[0].strengthLevel).toBe(1);
      expect(monsters[0].defenceLevel).toBe(90);
      expect(monsters[0].magicLevel).toBe(105);
      expect(monsters[0].rangedLevel).toBe(1);
      expect(monsters[0].attackSpeed).toBe(4);
      expect(monsters[0].attackStyle).toBe('Magic');
      expect(monsters[0].maxHit).toBe('8, 14 (without Nose peg)');
      expect(monsters[0].size).toBe(2);
      expect(monsters[0].aggressive).toBe(true);
      expect(monsters[0].poisonous).toBe(false);
      expect(monsters[0].attributes).toBe('undead, spectral');
      expect(monsters[0].elementalWeaknessType).toBe('Air');
      expect(monsters[0].elementalWeaknessPercent).toBe(50);
      expect(monsters[0].attackBonus).toBe(0);
      expect(monsters[0].strengthBonus).toBe(0);
      expect(monsters[0].magicAttackBonus).toBe(0);
      expect(monsters[0].magicDamageBonus).toBe(0);
      expect(monsters[0].rangedAttackBonus).toBe(0);
      expect(monsters[0].rangedStrengthBonus).toBe(0);
      expect(monsters[0].stabDefence).toBe(20);
      expect(monsters[0].slashDefence).toBe(20);
      expect(monsters[0].crushDefence).toBe(20);
      expect(monsters[0].magicDefence).toBe(0);
      expect(monsters[0].lightRangedDefence).toBe(0);
      expect(monsters[0].standardRangedDefence).toBe(-15);
      expect(monsters[0].heavyRangedDefence).toBe(0);
      expect(monsters[0].flatArmour).toBe(0);
      expect(monsters[0].xpBonus).toBe(0);
      expect(monsters[0].isMembers).toBe(true);
    });

    it('extracts slayer data from Aberrant Spectre', () => {
      const page = loadTestPage(TestPages.AberrantSpectre);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(1);
      expect(monsters[0].slayerLevel).toBe(60);
      expect(monsters[0].slayerXp).toBe(90);
      expect(monsters[0].slayerCategory).toBe('Aberrant Spectres');
      expect(monsters[0].assignedBy).toEqual([
        'vannaka',
        'chaeldar',
        'konar',
        'nieve',
        'duradel',
      ]);
    });

    it('extracts immunities from Aberrant Spectre', () => {
      const page = loadTestPage(TestPages.AberrantSpectre);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(1);
      expect(monsters[0].immuneToPoison).toBe(false);
      expect(monsters[0].immuneToVenom).toBe(false);
      expect(monsters[0].immuneToCannon).toBe(false);
      expect(monsters[0].immuneToThrall).toBe(false);
      expect(monsters[0].immuneToBurn).toBe('');
      expect(monsters[0].freezeResistance).toBe(0);
    });

    it('extracts positive immunities from A Doubt', () => {
      const page = loadTestPage(TestPages.ADoubt);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(1);
      expect(monsters[0].immuneToPoison).toBe(true);
      expect(monsters[0].immuneToVenom).toBe(true);
      expect(monsters[0].immuneToCannon).toBe(false);
      expect(monsters[0].immuneToThrall).toBe(false);
      expect(monsters[0].immuneToBurn).toBe('');
      expect(monsters[0].freezeResistance).toBe(0);
    });

    it('parses poisonous as a string value from King Black Dragon', () => {
      const page = loadTestPage(TestPages.KingBlackDragon);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(1);
      expect(monsters[0].id).toBe(239);
      expect(monsters[0].poisonous).toBe('Yes (8)');
      expect(monsters[0].combatLevel).toBe(276);
      expect(monsters[0].hitpoints).toBe(240);
      expect(monsters[0].attackSpeed).toBe(4);
      expect(monsters[0].aggressive).toBe(true);
    });

    it('parses immuneToBurn string and immunities from Jal-ImKot', () => {
      const page = loadTestPage(TestPages.JalImKot);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(1);
      expect(monsters[0].id).toBe(7697);
      expect(monsters[0].immuneToPoison).toBe(true);
      expect(monsters[0].immuneToVenom).toBe(true);
      expect(monsters[0].immuneToBurn).toBe('Immune to normal burn');
      expect(monsters[0].combatLevel).toBe(240);
      expect(monsters[0].hitpoints).toBe(75);
      expect(monsters[0].attackSpeed).toBe(4);
      expect(monsters[0].aggressive).toBe(true);
    });

    it('extracts full immunities, freeze resistance, and split ranged defences from Surok Magis', () => {
      const page = loadTestPage(TestPages.SurokMagis);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(1);
      expect(monsters[0].id).toBe(13482);
      expect(monsters[0].name).toBe('Surok Magis');
      expect(monsters[0].combatLevel).toBe(265);
      expect(monsters[0].hitpoints).toBe(450);
      expect(monsters[0].attackLevel).toBe(1);
      expect(monsters[0].strengthLevel).toBe(1);
      expect(monsters[0].defenceLevel).toBe(160);
      expect(monsters[0].magicLevel).toBe(160);
      expect(monsters[0].rangedLevel).toBe(1);
      expect(monsters[0].attackSpeed).toBe(5);
      expect(monsters[0].attackStyle).toBe('Magic');
      expect(monsters[0].attackBonus).toBe(0);
      expect(monsters[0].strengthBonus).toBe(0);
      expect(monsters[0].magicAttackBonus).toBe(85);
      expect(monsters[0].magicDamageBonus).toBe(105);
      expect(monsters[0].rangedAttackBonus).toBe(0);
      expect(monsters[0].rangedStrengthBonus).toBe(0);
      expect(monsters[0].stabDefence).toBe(30);
      expect(monsters[0].slashDefence).toBe(20);
      expect(monsters[0].crushDefence).toBe(40);
      expect(monsters[0].magicDefence).toBe(0);
      expect(monsters[0].lightRangedDefence).toBe(20);
      expect(monsters[0].standardRangedDefence).toBe(20);
      expect(monsters[0].heavyRangedDefence).toBe(20);
      expect(monsters[0].immuneToPoison).toBe(true);
      expect(monsters[0].immuneToVenom).toBe(true);
      expect(monsters[0].immuneToCannon).toBe(true);
      expect(monsters[0].immuneToThrall).toBe(false);
      expect(monsters[0].immuneToBurn).toBe('');
      expect(monsters[0].freezeResistance).toBe(100);
      expect(monsters[0].aggressive).toBe(true);
      expect(monsters[0].isMembers).toBe(true);
    });

    it('returns 3 variants for Fire Giant with correct IDs and combat levels', () => {
      const page = loadTestPage(TestPages.FireGiant);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(3);
      expect(monsters[0].id).toBe(2075);
      expect(monsters[1].id).toBe(7252);
      expect(monsters[2].id).toBe(7251);
      expect(monsters[0].combatLevel).toBe(86);
      expect(monsters[1].combatLevel).toBe(104);
      expect(monsters[2].combatLevel).toBe(109);
      expect(monsters[0].size).toBe(2);
      expect(monsters[0].isMembers).toBe(true);
    });

    it('existing drop parsing still works (regression)', () => {
      const page = loadTestPage(TestPages.AberrantSpectre);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(1);
      expect(monsters[0].drops).toContainEqual({
        name: 'Steel axe',
        quantity: '1',
        rarity: '3/128',
        itemId: null,
      });
      expect(monsters[0].dropTables).toContainEqual({
        type: 'gem_drop_table',
        rarity: '5/128',
        chaosTalisman: true,
        natureTalisman: true,
      });
    });
  });

  describe('monster locations', () => {
    it('parses all LocLine locations from Cow (shared across variants)', () => {
      const page = loadTestPage(TestPages.Cow);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      // Cow has 5 variants, all sharing the same location list
      expect(monsters.length).toBe(5);
      for (const monster of monsters) {
        expect(monster.locations).toHaveLength(15);
      }

      const first = monsters[0].locations[0];
      expect(first.name).toBe('Cow');
      expect(first.location).toBe('Ardougne Farm');
      expect(first.levels).toBe('2');
      expect(first.members).toBe(true);
      expect(first.mapId).toBe(0);
      expect(first.mtype).toBe('pin');
      expect(first.coordinates.length).toBeGreaterThan(0);
      expect(first.coordinates[0]).toEqual({ x: 2657, y: 3341 });
    });

    it('parses coordinates from a multi-spawn location', () => {
      const page = loadTestPage(TestPages.Cow);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      const lumbridge = monsters[0].locations.find((l) =>
        l.location.includes('Champions')
      );
      expect(lumbridge).toBeDefined();
      expect(lumbridge!.coordinates.length).toBeGreaterThan(10);
    });

    it('returns empty locations when a monster page has no LocLine', () => {
      const page = loadTestPage(TestPages.ADoubt);
      const monsters = parseMonsterFromContent(
        page.text,
        page.title,
        page.aliases,
        itemLookup
      );

      expect(monsters).toHaveLength(1);
      expect(monsters[0].locations).toEqual([]);
    });
  });
});
