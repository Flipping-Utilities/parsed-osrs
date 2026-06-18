export interface Prayer {
  name: string;
  aliases: string[];
  level: number;
  drain: number;
  members: boolean;
  effect: string;
  image?: string | string[];
}
