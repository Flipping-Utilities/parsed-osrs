import { createClient, type Client } from '@libsql/client';
import { drizzle } from 'drizzle-orm/libsql';

import {
  item,
  equipmentStats,
  monster,
  monsterDrop,
  monsterDropTable,
  shop,
  shopItem,
  recipe,
  recipeSkill,
  recipeMaterial,
  itemSet,
  setComponent,
  itemSpawn,
} from '../src/modules/database/output-schema';
import type { Item, ItemSpawn } from '../src/types/item';
import type { Monster } from '../src/types/monster';
import type { Shop } from '../src/types/shops';
import type { Recipe } from '../src/types/recipe';
import type { Set as ItemSetData } from '../src/types/sets';
import * as fs from 'fs';
import * as path from 'path';

const DB_PATH = path.resolve(__dirname, '../data/database.sqlite');
const DATA_DIR = path.resolve(__dirname, '../data');
const BATCH_SIZE = 500;

function readJsonFile<T>(filePath: string): T[] | null {
  if (!fs.existsSync(filePath)) {
    console.log(`  Skipping ${path.basename(filePath)} (not found)`);
    return null;
  }
  const raw = fs.readFileSync(filePath, 'utf-8');
  return JSON.parse(raw) as T[];
}

function batchInsert(
  rows: unknown[],
  label: string,
  doInsert: (batch: unknown[]) => void,
) {
  if (rows.length === 0) {
    console.log(`  ${label}: 0 rows`);
    return;
  }
  for (let i = 0; i < rows.length; i += BATCH_SIZE) {
    doInsert(rows.slice(i, i + BATCH_SIZE));
  }
  console.log(`  ${label}: ${rows.length} rows`);
}

function toItemRows(items: Item[]) {
  const itemRows: unknown[] = [];
  const statsRows: unknown[] = [];

  for (const it of items) {
    itemRows.push({
      id: it.id,
      name: it.name,
      examine: it.examine,
      image: it.image ?? null,
      aliases: it.aliases ?? [],
      isTradeable: it.isTradeable,
      isOnGrandExchange: it.isOnGrandExchange,
      isMembers: it.isMembers,
      isStackable: it.isStackable,
      isEquipable: it.isEquipable,
      isAlchable: it.isAlchable,
      isEdible: it.isEdible,
      isBankable: it.isBankable,
      isNoteable: it.isNoteable,
      stacksInBank: it.stacksInBank,
      isPlaceholder: it.isPlaceholder,
      isInMainGame: it.isInMainGame,
      value: it.value,
      weight: it.weight,
      limit: it.limit,
      quest: it.quest,
      drop: it.drop,
      geName: it.geName,
      respawnTime: it.respawnTime,
      options: it.options,
      wornOptions: it.wornOptions,
      relatedItems: it.relatedItems,
    });

    if (it.equipmentStats) {
      const s = it.equipmentStats;
      statsRows.push({
        itemId: it.id,
        attackStab: s.attackStab,
        attackSlash: s.attackSlash,
        attackCrush: s.attackCrush,
        attackMagic: s.attackMagic,
        attackRanged: s.attackRanged,
        defendStab: s.defendStab,
        defendSlash: s.defendSlash,
        defendCrush: s.defendCrush,
        defendMagic: s.defendMagic,
        defendRanged: s.defendRanged,
        strength: s.strength,
        rangedStrength: s.rangedStrength,
        magicDamage: s.magicDamage,
        prayer: s.prayer,
        slot: s.slot,
        speed: s.speed,
        attackRange: s.attackRange,
        combatStyle: s.combatStyle,
      });
    }
  }

  return { itemRows, statsRows };
}

function toMonsterRows(monsters: Monster[]) {
  const monsterRows: unknown[] = [];
  const dropRows: unknown[] = [];
  const dropTableRows: unknown[] = [];

  for (const m of monsters) {
    monsterRows.push({
      id: m.id,
      name: m.name,
      examine: m.examine,
      aliases: m.aliases,
      combatLevel: m.combatLevel,
      hitpoints: m.hitpoints,
      attackLevel: m.attackLevel,
      strengthLevel: m.strengthLevel,
      defenceLevel: m.defenceLevel,
      magicLevel: m.magicLevel,
      rangedLevel: m.rangedLevel,
      attackSpeed: m.attackSpeed,
      attackStyle: m.attackStyle,
      maxHit: m.maxHit,
      attackBonus: m.attackBonus,
      strengthBonus: m.strengthBonus,
      magicAttackBonus: m.magicAttackBonus,
      magicDamageBonus: m.magicDamageBonus,
      rangedAttackBonus: m.rangedAttackBonus,
      rangedStrengthBonus: m.rangedStrengthBonus,
      stabDefence: m.stabDefence,
      slashDefence: m.slashDefence,
      crushDefence: m.crushDefence,
      magicDefence: m.magicDefence,
      lightRangedDefence: m.lightRangedDefence,
      standardRangedDefence: m.standardRangedDefence,
      heavyRangedDefence: m.heavyRangedDefence,
      flatArmour: m.flatArmour,
      elementalWeaknessType: m.elementalWeaknessType,
      elementalWeaknessPercent: m.elementalWeaknessPercent,
      slayerLevel: m.slayerLevel,
      slayerXp: m.slayerXp,
      slayerCategory: m.slayerCategory,
      assignedBy: m.assignedBy,
      immuneToPoison: m.immuneToPoison,
      immuneToVenom: m.immuneToVenom,
      immuneToCannon: m.immuneToCannon,
      immuneToThrall: m.immuneToThrall,
      immuneToBurn: m.immuneToBurn,
      freezeResistance: m.freezeResistance,
      isMembers: m.isMembers,
      aggressive: m.aggressive,
      poisonous: typeof m.poisonous === 'boolean' ? JSON.stringify(m.poisonous) : m.poisonous,
      size: m.size,
      attributes: m.attributes,
      xpBonus: m.xpBonus,
    });

    for (const d of m.drops) {
      dropRows.push({
        monsterId: m.id,
        name: d.name,
        itemId: d.itemId,
        quantity: d.quantity ?? '',
        rarity: d.rarity ?? '',
      });
    }

    for (const dt of m.dropTables) {
      dropTableRows.push({
        monsterId: m.id,
        type: dt.type,
        rarity: dt.rarity ?? '',
        rolls: dt.rolls ?? '',
        combat: dt.combat ?? '',
        hitpoints: dt.hitpoints ?? '',
        boss: dt.boss ?? false,
        superior: dt.superior ?? false,
        chaosTalisman: dt.chaosTalisman ?? false,
        natureTalisman: dt.natureTalisman ?? false,
      });
    }
  }

  return { monsterRows, dropRows, dropTableRows };
}

function createSchema(client: Client) {
  const ddl = [
    `CREATE TABLE IF NOT EXISTS item (
      id INTEGER PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      examine TEXT NOT NULL DEFAULT '',
      image TEXT,
      aliases TEXT NOT NULL DEFAULT '[]',
      is_tradeable INTEGER NOT NULL DEFAULT 0,
      is_on_grand_exchange INTEGER NOT NULL DEFAULT 0,
      is_members INTEGER,
      is_stackable INTEGER NOT NULL DEFAULT 0,
      is_equipable INTEGER NOT NULL DEFAULT 0,
      is_alchable INTEGER NOT NULL DEFAULT 0,
      is_edible INTEGER NOT NULL DEFAULT 0,
      is_bankable INTEGER NOT NULL DEFAULT 1,
      is_noteable INTEGER NOT NULL DEFAULT 0,
      stacks_in_bank INTEGER NOT NULL DEFAULT 1,
      is_placeholder INTEGER NOT NULL DEFAULT 0,
      is_in_main_game INTEGER,
      value INTEGER NOT NULL DEFAULT 0,
      weight INTEGER,
      "limit" INTEGER NOT NULL DEFAULT 0,
      quest TEXT NOT NULL DEFAULT '',
      drop_action TEXT NOT NULL DEFAULT '',
      ge_name TEXT NOT NULL DEFAULT '',
      respawn_time INTEGER NOT NULL DEFAULT 0,
      options TEXT NOT NULL DEFAULT '[]',
      worn_options TEXT NOT NULL DEFAULT '[]',
      related_items TEXT NOT NULL DEFAULT '[]'
    )`,
    `CREATE TABLE IF NOT EXISTS equipment_stats (
      item_id INTEGER PRIMARY KEY NOT NULL REFERENCES item(id) ON DELETE CASCADE,
      attack_stab INTEGER NOT NULL DEFAULT 0,
      attack_slash INTEGER NOT NULL DEFAULT 0,
      attack_crush INTEGER NOT NULL DEFAULT 0,
      attack_magic INTEGER NOT NULL DEFAULT 0,
      attack_ranged INTEGER NOT NULL DEFAULT 0,
      defend_stab INTEGER NOT NULL DEFAULT 0,
      defend_slash INTEGER NOT NULL DEFAULT 0,
      defend_crush INTEGER NOT NULL DEFAULT 0,
      defend_magic INTEGER NOT NULL DEFAULT 0,
      defend_ranged INTEGER NOT NULL DEFAULT 0,
      strength INTEGER NOT NULL DEFAULT 0,
      ranged_strength INTEGER NOT NULL DEFAULT 0,
      magic_damage INTEGER NOT NULL DEFAULT 0,
      prayer INTEGER NOT NULL DEFAULT 0,
      slot TEXT NOT NULL DEFAULT '',
      speed INTEGER NOT NULL DEFAULT 0,
      attack_range INTEGER NOT NULL DEFAULT 0,
      combat_style TEXT NOT NULL DEFAULT ''
    )`,
    `CREATE TABLE IF NOT EXISTS item_set (
      id INTEGER PRIMARY KEY NOT NULL,
      name TEXT NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS set_component (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      set_id INTEGER NOT NULL REFERENCES item_set(id) ON DELETE CASCADE,
      item_id INTEGER NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS item_spawn (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      item_id INTEGER NOT NULL,
      name TEXT NOT NULL DEFAULT '',
      quantity INTEGER NOT NULL DEFAULT 0,
      x INTEGER NOT NULL DEFAULT 0,
      y INTEGER NOT NULL DEFAULT 0,
      plane INTEGER NOT NULL DEFAULT 0,
      location TEXT NOT NULL DEFAULT '',
      members INTEGER NOT NULL DEFAULT 0
    )`,
    `CREATE TABLE IF NOT EXISTS shop (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT NOT NULL,
      page_id INTEGER,
      sell_percent INTEGER NOT NULL DEFAULT 0,
      buy_percent INTEGER NOT NULL DEFAULT 0,
      buy_change_percent INTEGER NOT NULL DEFAULT 0
    )`,
    `CREATE TABLE IF NOT EXISTS shop_item (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      shop_id INTEGER NOT NULL REFERENCES shop(id) ON DELETE CASCADE,
      item_id INTEGER,
      base_quantity INTEGER NOT NULL DEFAULT 0,
      restock_time INTEGER NOT NULL DEFAULT 0
    )`,
    `CREATE TABLE IF NOT EXISTS recipe (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT NOT NULL DEFAULT '',
      notes TEXT NOT NULL DEFAULT '',
      facility TEXT NOT NULL DEFAULT '',
      members INTEGER NOT NULL DEFAULT 0,
      ticks INTEGER,
      ticks_note TEXT NOT NULL DEFAULT '',
      tool_ids TEXT NOT NULL DEFAULT '[]'
    )`,
    `CREATE TABLE IF NOT EXISTS recipe_skill (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      recipe_id INTEGER NOT NULL REFERENCES recipe(id) ON DELETE CASCADE,
      name TEXT NOT NULL DEFAULT '',
      level INTEGER NOT NULL DEFAULT 0,
      boostable INTEGER NOT NULL DEFAULT 0,
      xp INTEGER NOT NULL DEFAULT 0
    )`,
    `CREATE TABLE IF NOT EXISTS recipe_material (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      recipe_id INTEGER NOT NULL REFERENCES recipe(id) ON DELETE CASCADE,
      direction TEXT NOT NULL DEFAULT 'input',
      item_id INTEGER,
      quantity INTEGER NOT NULL DEFAULT 0,
      cost INTEGER,
      notes TEXT NOT NULL DEFAULT '',
      text TEXT NOT NULL DEFAULT '',
      sub_text TEXT NOT NULL DEFAULT ''
    )`,
    `CREATE TABLE IF NOT EXISTS monster (
      id INTEGER PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      examine TEXT NOT NULL DEFAULT '',
      aliases TEXT NOT NULL DEFAULT '[]',
      combat_level INTEGER NOT NULL DEFAULT 0,
      hitpoints INTEGER NOT NULL DEFAULT 0,
      attack_level INTEGER NOT NULL DEFAULT 0,
      strength_level INTEGER NOT NULL DEFAULT 0,
      defence_level INTEGER NOT NULL DEFAULT 0,
      magic_level INTEGER NOT NULL DEFAULT 0,
      ranged_level INTEGER NOT NULL DEFAULT 0,
      attack_speed INTEGER NOT NULL DEFAULT 0,
      attack_style TEXT NOT NULL DEFAULT '',
      max_hit TEXT NOT NULL DEFAULT '',
      attack_bonus INTEGER NOT NULL DEFAULT 0,
      strength_bonus INTEGER NOT NULL DEFAULT 0,
      magic_attack_bonus INTEGER NOT NULL DEFAULT 0,
      magic_damage_bonus INTEGER NOT NULL DEFAULT 0,
      ranged_attack_bonus INTEGER NOT NULL DEFAULT 0,
      ranged_strength_bonus INTEGER NOT NULL DEFAULT 0,
      stab_defence INTEGER NOT NULL DEFAULT 0,
      slash_defence INTEGER NOT NULL DEFAULT 0,
      crush_defence INTEGER NOT NULL DEFAULT 0,
      magic_defence INTEGER NOT NULL DEFAULT 0,
      light_ranged_defence INTEGER NOT NULL DEFAULT 0,
      standard_ranged_defence INTEGER NOT NULL DEFAULT 0,
      heavy_ranged_defence INTEGER NOT NULL DEFAULT 0,
      flat_armour INTEGER NOT NULL DEFAULT 0,
      elemental_weakness_type TEXT NOT NULL DEFAULT '',
      elemental_weakness_percent INTEGER NOT NULL DEFAULT 0,
      slayer_level INTEGER NOT NULL DEFAULT 0,
      slayer_xp INTEGER NOT NULL DEFAULT 0,
      slayer_category TEXT NOT NULL DEFAULT '',
      assigned_by TEXT NOT NULL DEFAULT '[]',
      immune_to_poison INTEGER NOT NULL DEFAULT 0,
      immune_to_venom INTEGER NOT NULL DEFAULT 0,
      immune_to_cannon INTEGER NOT NULL DEFAULT 0,
      immune_to_thrall INTEGER NOT NULL DEFAULT 0,
      immune_to_burn TEXT NOT NULL DEFAULT '',
      freeze_resistance INTEGER NOT NULL DEFAULT 0,
      is_members INTEGER NOT NULL DEFAULT 0,
      aggressive INTEGER NOT NULL DEFAULT 0,
      poisonous TEXT NOT NULL DEFAULT '',
      size INTEGER NOT NULL DEFAULT 1,
      attributes TEXT NOT NULL DEFAULT '',
      xp_bonus INTEGER NOT NULL DEFAULT 0
    )`,
    `CREATE TABLE IF NOT EXISTS monster_drop (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      monster_id INTEGER NOT NULL REFERENCES monster(id) ON DELETE CASCADE,
      name TEXT NOT NULL DEFAULT '',
      item_id INTEGER,
      quantity TEXT NOT NULL DEFAULT '',
      rarity TEXT NOT NULL DEFAULT ''
    )`,
    `CREATE TABLE IF NOT EXISTS monster_drop_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      monster_id INTEGER NOT NULL REFERENCES monster(id) ON DELETE CASCADE,
      type TEXT NOT NULL DEFAULT '',
      rarity TEXT NOT NULL DEFAULT '',
      rolls TEXT NOT NULL DEFAULT '',
      combat TEXT NOT NULL DEFAULT '',
      hitpoints TEXT NOT NULL DEFAULT '',
      boss INTEGER NOT NULL DEFAULT 0,
      superior INTEGER NOT NULL DEFAULT 0,
      chaos_talisman INTEGER NOT NULL DEFAULT 0,
      nature_talisman INTEGER NOT NULL DEFAULT 0
    )`,
  ];

  for (const stmt of ddl) {
    client.execute(stmt);
  }
}

async function main() {
  console.log('Building database...');
  console.time('Total');

  if (fs.existsSync(DB_PATH)) {
    fs.unlinkSync(DB_PATH);
    console.log('Deleted existing database');
  }

  const dbUrl = DB_PATH.replace(/\\/g, '/');
  const client = createClient({ url: `file:${dbUrl}` });
  const db = drizzle(client);

  client.execute('PRAGMA foreign_keys = ON;');
  client.execute('PRAGMA journal_mode = WAL;');
  client.execute('PRAGMA synchronous = OFF;');

  createSchema(client);
  console.log('Schema created');

  console.log('Reading JSON files...');
  const items = readJsonFile<Item>(path.join(DATA_DIR, 'items/all-items.json'));
  const monsters = readJsonFile<Monster>(path.join(DATA_DIR, 'monsters/all-monsters.json'));
  const shops = readJsonFile<Shop>(path.join(DATA_DIR, 'items/all-shops.json'));
  const recipes = readJsonFile<Recipe>(path.join(DATA_DIR, 'items/all-recipes.json'));
  const sets = readJsonFile<ItemSetData>(path.join(DATA_DIR, 'items/all-sets.json'));
  const spawns = readJsonFile<ItemSpawn>(path.join(DATA_DIR, 'items/all-spawns.json'));

  console.log('Inserting data...');

  if (items) {
    const { itemRows, statsRows } = toItemRows(items);
    batchInsert(itemRows, 'item', (batch) => { db.insert(item).values(batch as typeof item.$inferInsert[]).run(); });
    batchInsert(statsRows, 'equipment_stats', (batch) => { db.insert(equipmentStats).values(batch as typeof equipmentStats.$inferInsert[]).run(); });
  }

  if (sets) {
    const setRows: unknown[] = [];
    const componentRows: unknown[] = [];
    for (const s of sets) {
      setRows.push({ id: s.id, name: s.name });
      for (const cid of s.componentIds) {
        componentRows.push({ setId: s.id, itemId: cid });
      }
    }
    batchInsert(setRows, 'item_set', (batch) => { db.insert(itemSet).values(batch as typeof itemSet.$inferInsert[]).run(); });
    batchInsert(componentRows, 'set_component', (batch) => { db.insert(setComponent).values(batch as typeof setComponent.$inferInsert[]).run(); });
  }

  if (spawns) {
    const spawnRows = spawns.map(s => ({
      itemId: s.id,
      name: s.name,
      quantity: s.quantity,
      x: s.x,
      y: s.y,
      plane: s.plane,
      location: s.location,
      members: s.members,
    }));
    batchInsert(spawnRows, 'item_spawn', (batch) => { db.insert(itemSpawn).values(batch as typeof itemSpawn.$inferInsert[]).run(); });
  }

  if (shops) {
    const shopItemRows: unknown[] = [];
    let shopIdCounter = 1;

    for (const s of shops) {
      const currentShopId = shopIdCounter++;
      db.insert(shop).values({
        name: s.name,
        pageId: s.pageId,
        sellPercent: s.sellPercent,
        buyPercent: s.buyPercent,
        buyChangePercent: s.buyChangePercent,
      }).run();

      for (const inv of s.inventory) {
        shopItemRows.push({
          shopId: currentShopId,
          itemId: inv.itemId,
          baseQuantity: inv.baseQuantity,
          restockTime: inv.restockTime,
        });
      }
    }
    console.log(`  shop: ${shops.length} rows`);
    batchInsert(shopItemRows, 'shop_item', (batch) => { db.insert(shopItem).values(batch as typeof shopItem.$inferInsert[]).run(); });
  }

  if (recipes) {
    const skillRows: unknown[] = [];
    const materialRows: unknown[] = [];
    let recipeIdCounter = 1;

    for (const r of recipes) {
      const currentRecipeId = recipeIdCounter++;
      db.insert(recipe).values({
        name: r.name ?? '',
        notes: r.notes ?? '',
        facility: r.facility ?? '',
        members: r.members,
        ticks: r.ticks,
        ticksNote: r.ticksNote ?? '',
        toolIds: r.toolIds,
      }).run();

      for (const sk of r.skills) {
        skillRows.push({
          recipeId: currentRecipeId,
          name: sk.name,
          level: sk.lvl,
          boostable: sk.boostable,
          xp: sk.xp,
        });
      }

      for (const inp of r.inputs) {
        materialRows.push({
          recipeId: currentRecipeId,
          direction: 'input' as const,
          itemId: inp.id,
          quantity: inp.quantity,
          cost: inp.cost ?? null,
          notes: inp.notes ?? '',
          text: inp.text ?? '',
          subText: inp.subText ?? '',
        });
      }

      for (const out of r.outputs) {
        materialRows.push({
          recipeId: currentRecipeId,
          direction: 'output' as const,
          itemId: out.id,
          quantity: out.quantity,
          cost: out.cost ?? null,
          notes: out.notes ?? '',
          text: out.text ?? '',
          subText: out.subText ?? '',
        });
      }
    }
    console.log(`  recipe: ${recipes.length} rows`);
    batchInsert(skillRows, 'recipe_skill', (batch) => { db.insert(recipeSkill).values(batch as typeof recipeSkill.$inferInsert[]).run(); });
    batchInsert(materialRows, 'recipe_material', (batch) => { db.insert(recipeMaterial).values(batch as typeof recipeMaterial.$inferInsert[]).run(); });
  }

  if (monsters) {
    const { monsterRows, dropRows, dropTableRows } = toMonsterRows(monsters);
    batchInsert(monsterRows, 'monster', (batch) => { db.insert(monster).values(batch as typeof monster.$inferInsert[]).run(); });
    batchInsert(dropRows, 'monster_drop', (batch) => { db.insert(monsterDrop).values(batch as typeof monsterDrop.$inferInsert[]).run(); });
    batchInsert(dropTableRows, 'monster_drop_table', (batch) => { db.insert(monsterDropTable).values(batch as typeof monsterDropTable.$inferInsert[]).run(); });
  }

  client.execute('PRAGMA synchronous = NORMAL;');

  console.log('');
  console.log('Database built successfully');
  console.log(`  Location: ${DB_PATH}`);
  console.timeEnd('Total');
}

main().catch((err) => {
  console.error('Failed to build database:', err);
  process.exit(1);
});
