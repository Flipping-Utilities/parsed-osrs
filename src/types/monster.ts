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

export interface Monster {
  id: number;
  name: string;
  examine: string;
  aliases: string[];
  drops: MonsterDrop[];
  dropTables: DropTable[];
}
