import { MapPoint, MapPolygon } from '../types';

export interface ParsedMap {
  mtype: string;
  name?: string;
  point?: MapPoint;
  polygon?: MapPolygon;
}

const POLYGON_IGNORED_KEYS = new Set([
  'template',
  'name',
  'mtype',
  'type',
  'x',
  'y',
  'r',
  'zoom',
  'plane',
  'mapid',
  'rectx',
  'recty',
]);

function toNumber(value: unknown): number | null {
  if (value === null || value === undefined) return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

function getPositionalValues(tmpl: Record<string, unknown>): string[] {
  const out: string[] = [];
  // wtf_wikipedia collects unnamed/positional params into a `list` array.
  const list = tmpl.list;
  if (Array.isArray(list)) {
    out.push(...list.map((v) => String(v)));
  }
  for (const [key, value] of Object.entries(tmpl)) {
    if (/^\d+$/.test(key) && typeof value === 'string') {
      out.push(value);
    }
  }
  return out;
}

/**
 * Parses a polygon's coordinate vertices from a {{Map|...|mtype=polygon|...}}
 * template. Handles both `x:y,x:y` (single positional param) and
 * `x,y|x,y|...` (multiple positional params) notations via a unified regex.
 */
function parsePolygon(tmpl: Record<string, unknown>): MapPolygon | null {
  const parts: string[] = getPositionalValues(tmpl);
  if (parts.length === 0) {
    // Fallback: any non-ignored string value
    for (const [key, value] of Object.entries(tmpl)) {
      if (POLYGON_IGNORED_KEYS.has(key)) continue;
      if (typeof value === 'string') parts.push(value);
    }
  }
  const joined = parts.join(',');

  const vertices: Array<{ x: number; y: number }> = [];
  const re = /(\d+)[,:](\d+)/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(joined)) !== null) {
    vertices.push({ x: Number(m[1]), y: Number(m[2]) });
  }
  if (!vertices.length) return null;

  const cx = Math.round(
    vertices.reduce((s, v) => s + v.x, 0) / vertices.length
  );
  const cy = Math.round(
    vertices.reduce((s, v) => s + v.y, 0) / vertices.length
  );
  return { raw: joined, vertices, centroid: { x: cx, y: cy } };
}

/**
 * Parses a single-point position from pin/rectangle/square {{Map|...}} markers.
 * Prefers explicit `x`/`y` named params, then falls back to the first positional
 * `x,y` pair.
 */
function parsePoint(tmpl: Record<string, unknown>): MapPoint | null {
  const x = toNumber(tmpl.x);
  const y = toNumber(tmpl.y);
  if (x !== null && y !== null) {
    return { x, y };
  }
  for (const value of getPositionalValues(tmpl)) {
    const m = value.match(/(\d+)[,:](\d+)/);
    if (m) {
      return { x: Number(m[1]), y: Number(m[2]) };
    }
  }
  return null;
}

/**
 * Parses a {{Map|...}} template into a structured result. Returns a polygon for
 * `mtype=polygon`, a point for pin/rectangle/square markers, or just the
 * `name`/`mtype` when no coordinates could be parsed.
 */
export function parseMapTemplate(
  tmpl: Record<string, unknown>
): ParsedMap | null {
  const mtype = String(tmpl.mtype ?? '').toLowerCase();
  const name = tmpl.name ? String(tmpl.name) : undefined;

  if (mtype === 'polygon') {
    const polygon = parsePolygon(tmpl);
    return polygon ? { mtype, name, polygon } : { mtype, name };
  }

  const point = parsePoint(tmpl);
  if (point) {
    return { mtype: mtype || 'pin', name, point };
  }
  return name ? { mtype, name } : null;
}
