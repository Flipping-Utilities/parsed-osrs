export interface Scenery {
  // Primary (first) object ID
  id: number;
  // All object IDs for this variant (some variants list several comma-separated)
  ids: number[];
  name: string;
  aliases: string[];
  members: boolean | null;
  quest: string;
  location: string;
  options: string[];
  examine: string;
}
