import { MapPoint } from './location';

export interface Quest {
  name: string;
  aliases: string[];
  // Quest number (release order)
  number: number;
  members: boolean;
  series: string;
  difficulty: string;
  length: string;
  // Start NPC / location description
  start: string;
  startCoords?: MapPoint;
  description: string;
  itemRequirements: string[];
  questPoints: number;
  // Raw reward lines (XP lamps, items, unlocks)
  rewards: string[];
}
