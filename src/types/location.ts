export interface MapPoint {
  x: number;
  y: number;
}

export interface MapPolygon {
  // The raw polygon parameter string from {{Map|...}}
  raw: string;
  // Parsed vertices of the boundary
  vertices: Array<{ x: number; y: number }>;
  // Approximate center (average of vertices) for nearest-area lookups
  centroid: { x: number; y: number };
}

export interface RelativeLocation {
  north?: string;
  south?: string;
  east?: string;
  west?: string;
}

export interface GameLocation {
  name: string;
  aliases: string[];
  // region, settlement, city, dungeon, etc.
  type: string;
  members: boolean;
  // Parent region/location (e.g. "Misthalin" for Varrock)
  region?: string;
  // Capital city, for regions
  capital?: string;
  // League region classification
  leagueRegion?: string;
  relativeLocation?: RelativeLocation;
  // Boundary polygon when an inline {{Map|...|mtype=polygon|...}} is present
  polygon?: MapPolygon;
  // Single-point position when a pin/rectangle/square {{Map|...}} is present
  position?: MapPoint;
}
