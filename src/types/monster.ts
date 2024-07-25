export interface MonsterCombatStats {
  attack: number;
  strength: number;
  defence: number;
  magic: number;
  ranged: number;

  attackBonus: number;
  strengthBonus: number;
  attackMagic: number;
  magicBonus: number;

  attackRanged: number;
  rangedBonus: number;
  defenceStab: number;
  defenceSlash: number;
  defenceCrush: number;
  defenceMagic: number;
  defenceRanged: number;

  immunePosion: boolean;
  immuneVenom: boolean;
  immuneCannon: boolean;
  immuneThrall: boolean;
}

export interface MonsterDrop {
  name: string;
  itemId: number | null;
  quantity?: string;
  rarity?: string;
}
export interface MonsterDropTable {
  name: string;
  drops: MonsterDrop[];
}
export interface Monster {
  id: number;
  ids: number[];

  version: string;
  name: string;
  image: string;
  release: string;
  update: string;
  removal?: string;
  removalUpdate?: string;
  members: boolean;
  level: number; // combat
  size: number;
  examine: string;
  xpBonus: number;
  maxHit: number;
  aggressive: boolean;
  poisonous: boolean;
  attackStyle: string;
  attackSpeed: number;
  slayXp: number;
  category: string;
  hitpoints: number;
  assignedBy: string[];
  combatStats: MonsterCombatStats;
  respawnTime: number;
  dropTable: string;
  aliases: string[];
}
