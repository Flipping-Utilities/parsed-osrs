import { integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const item = sqliteTable("item", {
  id: integer("id").primaryKey({ autoIncrement: false }).notNull(),
  name: text("name").notNull(),
  examine: text("examine").notNull().default(""),
  image: text("image", { mode: "json" }).$type<string | string[] | null>(),
  aliases: text("aliases", { mode: "json" }).$type<string[]>().notNull().default([]),
  isTradeable: integer("is_tradeable", { mode: "boolean" }).notNull().default(false),
  isOnGrandExchange: integer("is_on_grand_exchange", { mode: "boolean" }).notNull().default(false),
  isMembers: integer("is_members", { mode: "boolean" }),
  isStackable: integer("is_stackable", { mode: "boolean" }).notNull().default(false),
  isEquipable: integer("is_equipable", { mode: "boolean" }).notNull().default(false),
  isAlchable: integer("is_alchable", { mode: "boolean" }).notNull().default(false),
  isEdible: integer("is_edible", { mode: "boolean" }).notNull().default(false),
  isBankable: integer("is_bankable", { mode: "boolean" }).notNull().default(true),
  isNoteable: integer("is_noteable", { mode: "boolean" }).notNull().default(false),
  stacksInBank: integer("stacks_in_bank", { mode: "boolean" }).notNull().default(true),
  isPlaceholder: integer("is_placeholder", { mode: "boolean" }).notNull().default(false),
  isInMainGame: integer("is_in_main_game", { mode: "boolean" }),
  value: integer("value").notNull().default(0),
  weight: integer("weight"),
  limit: integer("limit").notNull().default(0),
  quest: text("quest").notNull().default(""),
  drop: text("drop_action").notNull().default(""),
  geName: text("ge_name").notNull().default(""),
  respawnTime: integer("respawn_time").notNull().default(0),
  options: text("options", { mode: "json" }).$type<string[]>().notNull().default([]),
  wornOptions: text("worn_options", { mode: "json" }).$type<string[]>().notNull().default([]),
  relatedItems: text("related_items", { mode: "json" }).$type<number[]>().notNull().default([]),
});

export const equipmentStats = sqliteTable("equipment_stats", {
  itemId: integer("item_id")
    .primaryKey({ autoIncrement: false })
    .notNull()
    .references(() => item.id, { onDelete: "cascade" }),
  attackStab: integer("attack_stab").notNull().default(0),
  attackSlash: integer("attack_slash").notNull().default(0),
  attackCrush: integer("attack_crush").notNull().default(0),
  attackMagic: integer("attack_magic").notNull().default(0),
  attackRanged: integer("attack_ranged").notNull().default(0),
  defendStab: integer("defend_stab").notNull().default(0),
  defendSlash: integer("defend_slash").notNull().default(0),
  defendCrush: integer("defend_crush").notNull().default(0),
  defendMagic: integer("defend_magic").notNull().default(0),
  defendRanged: integer("defend_ranged").notNull().default(0),
  strength: integer("strength").notNull().default(0),
  rangedStrength: integer("ranged_strength").notNull().default(0),
  magicDamage: integer("magic_damage").notNull().default(0),
  prayer: integer("prayer").notNull().default(0),
  slot: text("slot").notNull().default(""),
  speed: integer("speed").notNull().default(0),
  attackRange: integer("attack_range").notNull().default(0),
  combatStyle: text("combat_style").notNull().default(""),
});

export const monster = sqliteTable("monster", {
  id: integer("id").primaryKey({ autoIncrement: false }).notNull(),
  name: text("name").notNull(),
  examine: text("examine").notNull().default(""),
  aliases: text("aliases", { mode: "json" }).$type<string[]>().notNull().default([]),
  combatLevel: integer("combat_level").notNull().default(0),
  hitpoints: integer("hitpoints").notNull().default(0),
  attackLevel: integer("attack_level").notNull().default(0),
  strengthLevel: integer("strength_level").notNull().default(0),
  defenceLevel: integer("defence_level").notNull().default(0),
  magicLevel: integer("magic_level").notNull().default(0),
  rangedLevel: integer("ranged_level").notNull().default(0),
  attackSpeed: integer("attack_speed").notNull().default(0),
  attackStyle: text("attack_style").notNull().default(""),
  maxHit: text("max_hit").notNull().default(""),
  attackBonus: integer("attack_bonus").notNull().default(0),
  strengthBonus: integer("strength_bonus").notNull().default(0),
  magicAttackBonus: integer("magic_attack_bonus").notNull().default(0),
  magicDamageBonus: integer("magic_damage_bonus").notNull().default(0),
  rangedAttackBonus: integer("ranged_attack_bonus").notNull().default(0),
  rangedStrengthBonus: integer("ranged_strength_bonus").notNull().default(0),
  stabDefence: integer("stab_defence").notNull().default(0),
  slashDefence: integer("slash_defence").notNull().default(0),
  crushDefence: integer("crush_defence").notNull().default(0),
  magicDefence: integer("magic_defence").notNull().default(0),
  lightRangedDefence: integer("light_ranged_defence").notNull().default(0),
  standardRangedDefence: integer("standard_ranged_defence").notNull().default(0),
  heavyRangedDefence: integer("heavy_ranged_defence").notNull().default(0),
  flatArmour: integer("flat_armour").notNull().default(0),
  elementalWeaknessType: text("elemental_weakness_type").notNull().default(""),
  elementalWeaknessPercent: integer("elemental_weakness_percent").notNull().default(0),
  slayerLevel: integer("slayer_level").notNull().default(0),
  slayerXp: integer("slayer_xp").notNull().default(0),
  slayerCategory: text("slayer_category").notNull().default(""),
  assignedBy: text("assigned_by", { mode: "json" }).$type<string[]>().notNull().default([]),
  immuneToPoison: integer("immune_to_poison", { mode: "boolean" }).notNull().default(false),
  immuneToVenom: integer("immune_to_venom", { mode: "boolean" }).notNull().default(false),
  immuneToCannon: integer("immune_to_cannon", { mode: "boolean" }).notNull().default(false),
  immuneToThrall: integer("immune_to_thrall", { mode: "boolean" }).notNull().default(false),
  immuneToBurn: text("immune_to_burn").notNull().default(""),
  freezeResistance: integer("freeze_resistance").notNull().default(0),
  isMembers: integer("is_members", { mode: "boolean" }).notNull().default(false),
  aggressive: integer("aggressive", { mode: "boolean" }).notNull().default(false),
  poisonous: text("poisonous").notNull().default(""),
  size: integer("size").notNull().default(1),
  attributes: text("attributes").notNull().default(""),
  xpBonus: integer("xp_bonus").notNull().default(0),
});

export const monsterDrop = sqliteTable("monster_drop", {
  id: integer("id").primaryKey({ autoIncrement: true }).notNull(),
  monsterId: integer("monster_id")
    .notNull()
    .references(() => monster.id, { onDelete: "cascade" }),
  name: text("name").notNull().default(""),
  itemId: integer("item_id"),
  quantity: text("quantity").notNull().default(""),
  rarity: text("rarity").notNull().default(""),
});

export const monsterDropTable = sqliteTable("monster_drop_table", {
  id: integer("id").primaryKey({ autoIncrement: true }).notNull(),
  monsterId: integer("monster_id")
    .notNull()
    .references(() => monster.id, { onDelete: "cascade" }),
  type: text("type").notNull().default(""),
  rarity: text("rarity").notNull().default(""),
  rolls: text("rolls").notNull().default(""),
  combat: text("combat").notNull().default(""),
  hitpoints: text("hitpoints").notNull().default(""),
  boss: integer("boss", { mode: "boolean" }).notNull().default(false),
  superior: integer("superior", { mode: "boolean" }).notNull().default(false),
  chaosTalisman: integer("chaos_talisman", { mode: "boolean" }).notNull().default(false),
  natureTalisman: integer("nature_talisman", { mode: "boolean" }).notNull().default(false),
});

export const shop = sqliteTable("shop", {
  id: integer("id").primaryKey({ autoIncrement: true }).notNull(),
  name: text("name").notNull(),
  pageId: integer("page_id"),
  sellPercent: integer("sell_percent").notNull().default(0),
  buyPercent: integer("buy_percent").notNull().default(0),
  buyChangePercent: integer("buy_change_percent").notNull().default(0),
});

export const shopItem = sqliteTable("shop_item", {
  id: integer("id").primaryKey({ autoIncrement: true }).notNull(),
  shopId: integer("shop_id")
    .notNull()
    .references(() => shop.id, { onDelete: "cascade" }),
  itemId: integer("item_id"),
  baseQuantity: integer("base_quantity").notNull().default(0),
  restockTime: integer("restock_time").notNull().default(0),
});

export const recipe = sqliteTable("recipe", {
  id: integer("id").primaryKey({ autoIncrement: true }).notNull(),
  name: text("name").notNull().default(""),
  notes: text("notes").notNull().default(""),
  facility: text("facility").notNull().default(""),
  members: integer("members", { mode: "boolean" }).notNull().default(false),
  ticks: integer("ticks"),
  ticksNote: text("ticks_note").notNull().default(""),
  toolIds: text("tool_ids", { mode: "json" }).$type<number[]>().notNull().default([]),
});

export const recipeSkill = sqliteTable("recipe_skill", {
  id: integer("id").primaryKey({ autoIncrement: true }).notNull(),
  recipeId: integer("recipe_id")
    .notNull()
    .references(() => recipe.id, { onDelete: "cascade" }),
  name: text("name").notNull().default(""),
  level: integer("level").notNull().default(0),
  boostable: integer("boostable", { mode: "boolean" }).notNull().default(false),
  xp: integer("xp").notNull().default(0),
});

export const recipeMaterial = sqliteTable("recipe_material", {
  id: integer("id").primaryKey({ autoIncrement: true }).notNull(),
  recipeId: integer("recipe_id")
    .notNull()
    .references(() => recipe.id, { onDelete: "cascade" }),
  direction: text("direction").notNull().default("input"),
  itemId: integer("item_id"),
  quantity: integer("quantity").notNull().default(0),
  cost: integer("cost"),
  notes: text("notes").notNull().default(""),
  text: text("text").notNull().default(""),
  subText: text("sub_text").notNull().default(""),
});

export const itemSet = sqliteTable("item_set", {
  id: integer("id").primaryKey({ autoIncrement: false }).notNull(),
  name: text("name").notNull(),
});

export const setComponent = sqliteTable("set_component", {
  id: integer("id").primaryKey({ autoIncrement: true }).notNull(),
  setId: integer("set_id")
    .notNull()
    .references(() => itemSet.id, { onDelete: "cascade" }),
  itemId: integer("item_id").notNull(),
});

export const itemSpawn = sqliteTable("item_spawn", {
  id: integer("id").primaryKey({ autoIncrement: true }).notNull(),
  itemId: integer("item_id").notNull(),
  name: text("name").notNull().default(""),
  quantity: integer("quantity").notNull().default(0),
  x: integer("x").notNull().default(0),
  y: integer("y").notNull().default(0),
  plane: integer("plane").notNull().default(0),
  location: text("location").notNull().default(""),
  members: integer("members", { mode: "boolean" }).notNull().default(false),
});
