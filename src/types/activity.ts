import { MapPoint } from './location';

export interface Activity {
  name: string;
  aliases: string[];
  // Raid, Minigame, or Distraction & Diversion
  type: string;
  members: boolean;
  location: string;
  // Player count, e.g. "1-8" or "2-5"
  players: string;
  skills: string[];
  leagueRegion?: string;
  position?: MapPoint;
}
