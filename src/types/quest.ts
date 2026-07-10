import { MapPoint } from './location';

/**
 * One section of the main quest page's `==Walkthrough==` prose.
 *
 * The wiki nests the walkthrough as `==Walkthrough==` containing
 * `===Step===` and `====substep====` headings. We capture each subsection
 * (level >= 3) as a separate entry so consumers can present the quest as a
 * navigable list of steps.
 */
export interface WalkthroughSection {
  heading: string;
  body: string;
}

/**
 * One step group parsed from a `/Quick guide` subpage.
 *
 * The quick guide lays the quest out as `===section===` headings followed by
 * an optional italic items-needed line and a `{{Checklist|...}}` template
 * containing the actual bullet action items.
 */
export interface QuickGuideStep {
  section: string;
  itemsNeeded?: string;
  steps: string[];
}

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
  // Items required to start/finish from {{Quest details|items=...}}
  itemRequirements: string[];
  // Recommended items/info from {{Quest details|recommended=...}}
  recommendedItems: string[];
  // Skill / quest / combat requirements from {{Quest details|requirements=...}}
  requirements: string[];
  // Enemies to defeat from {{Quest details|kills=...}}
  enemiesToDefeat: string[];
  // Ironman-specific concerns from {{Quest details|ironman=...}}
  ironmanConcerns?: string;
  // League region info from {{Quest details|leagueRegion=...}} (stripped of markup)
  leagueRegion?: string;
  questPoints: number;
  // Reward lines (XP lamps, items, unlocks) — {{SCP|...}} resolved inline
  rewards: string[];
  // What completion of this quest unlocks (from ==Required for completing==)
  requiredFor: string[];
  // Detailed prose walkthrough from the main page's ==Walkthrough== section
  walkthrough?: WalkthroughSection[];
  // Concise step list parsed from the /Quick guide subpage ({{Checklist|...}})
  quickGuide?: QuickGuideStep[];
  // Optional Infobox Quest metadata
  image?: string;
  release?: string;
  update?: string;
  developer?: string;
}
