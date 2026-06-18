import { MapPoint, MapPolygon } from './location';

export interface MusicTrack {
  name: string;
  aliases: string[];
  // Track number when ordered by release date (optional on the wiki)
  number?: number;
  // Stable remote URL for the audio file (Special:FilePath redirection).
  fileUrl?: string;
  // Raw wiki filename as stored on the infobox, e.g. "Adventure.ogg"
  fileName?: string;
  // In-game cache ID of the track
  cacheId?: number;
  release?: string;
  update?: string;
  members: boolean;
  // Region / area name where the track plays or unlocks
  location?: string;
  // Unlock hint shown in the in-game music player
  hint?: string;
  // Associated quest name, or "No"
  quest?: string;
  // Optional seasonal / holiday event association
  event?: string;
  instruments?: string[];
  duration?: string;
  tempo?: string;
  signature?: string;
  composer?: string;
  album?: string;
  platform?: string[];
  // Sort name used by the in-game music list
  sortName?: string;
  // Long-form description of where/how the track unlocks
  unlockDetail?: string;
  // Boundary polygon where the track plays, from an inline {{Map|...|mtype=polygon}}
  polygon?: MapPolygon;
  // Single-point position from an inline pin/rectangle {{Map|...}}
  position?: MapPoint;
}
