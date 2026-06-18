export interface RuneCost {
  itemId: number | null;
  quantity: number;
}

export interface Spell {
  name: string;
  aliases: string[];
  level: number;
  spellbook: string;
  type: string;
  exp: number;
  members: boolean;
  description: string;
  cost: string;
  runeCost: RuneCost[];
  element?: string;
  damage?: string;
  speed?: number;
  image?: string | string[];
}
