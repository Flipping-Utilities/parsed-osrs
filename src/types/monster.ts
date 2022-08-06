export interface MonsterDrop {
  name: string;
  quantity?: string;
  rarity?: string;
}

export interface Monster {
  name: string;
  examine: string;
  aliases: string[];
  drops: MonsterDrop[];
}
