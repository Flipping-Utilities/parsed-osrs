export interface RecipeSkill {
  name: string;
  lvl: number;
  boostable: boolean;
  xp: number;
}
export interface RecipeMaterial {
  id: number;
  quantity: number;
  cost?: number;
  notes?: string;
  text?: string;
  subText?: string;
}
export interface Recipe {
  name?: string;
  notes?: string;
  facility?: string;
  skills: RecipeSkill[];
  members: boolean;
  ticks: number | null;
  ticksNote?: string;
  toolIds: number[];
  inputs: RecipeMaterial[];
  outputs: RecipeMaterial[];
}
