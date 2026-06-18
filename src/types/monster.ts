export interface MonsterDrop {
  name: string;
  itemId: number | null;
  quantity?: string;
  rarity?: string;
}

export type DropTableType =
  | 'rare_drop_table'
  | 'gem_drop_table'
  | 'herb_drop_table'
  | 'rare_seed_drop_table'
  | 'wilderness_slayer_table'
  | 'wilderness_slayer_cave_table'
  | 'catacombs_table'
  | 'superior_table'
  | 'bird_nest_table'
  | 'fossil_table';

export interface DropTable {
  type: DropTableType;
  rarity?: string;
  rolls?: string;
  combat?: string;
  hitpoints?: string;
  boss?: boolean;
  superior?: boolean;
  chaosTalisman?: boolean;
  natureTalisman?: boolean;
}

export interface MonsterLocation {
  name: string;
  location: string;
  levels: string;
  members: boolean;
  mapId: number;
  mtype?: string;
  coordinates: Array<{ x: number; y: number }>;
}

export interface Monster {
  id: number;
  name: string;
  examine: string;
  aliases: string[];
  combatLevel: number;
  hitpoints: number;
  attackLevel: number;
  strengthLevel: number;
  defenceLevel: number;
  magicLevel: number;
  rangedLevel: number;
  attackSpeed: number;
  attackStyle: string;
  maxHit: string;
  size: number;
  aggressive: boolean;
  poisonous: string | boolean;
  attributes: string;
  elementalWeaknessType: string;
  elementalWeaknessPercent: number;
  attackBonus: number;
  strengthBonus: number;
  magicAttackBonus: number;
  magicDamageBonus: number;
  rangedAttackBonus: number;
  rangedStrengthBonus: number;
  stabDefence: number;
  slashDefence: number;
  crushDefence: number;
  magicDefence: number;
  lightRangedDefence: number;
  standardRangedDefence: number;
  heavyRangedDefence: number;
  flatArmour: number;
  xpBonus: number;
  isMembers: boolean;
  slayerLevel: number;
  slayerXp: number;
  slayerCategory: string;
  assignedBy: string[];
  immuneToPoison: boolean;
  immuneToVenom: boolean;
  immuneToCannon: boolean;
  immuneToThrall: boolean;
  immuneToBurn: string;
  freezeResistance: number;
  drops: MonsterDrop[];
  dropTables: DropTable[];
  locations: MonsterLocation[];
}
