export interface MonsterDrop {
  name: string;
  itemId: number | null;
  quantity?: string;
  rarity?: string;
}

export interface Monster {
  id: number;
  name: string;
  examine: string;
  aliases: string[];
  drops: MonsterDrop[];
}
