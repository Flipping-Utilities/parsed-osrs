import { MapPoint } from "./location";

export interface NPC {
  id: number;
  name: string;
  aliases: string[];
  members: boolean;
  race: string;
  location: string;
  quest: string;
  gender: string;
  options: string[];
  examine: string;
  leagueRegion?: string;
  position?: MapPoint;
}
