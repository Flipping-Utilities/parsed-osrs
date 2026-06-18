import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import { parseLocationFromContent } from './locations.extractor';

describe('parseLocationFromContent', () => {
  it('parses Varrock settlement with region, league region, and adjacency', () => {
    const page = loadTestPage(TestPages.Varrock);

    const location = parseLocationFromContent(
      page.text,
      page.title,
      page.aliases
    );

    expect(location).not.toBeNull();
    expect(location!.name).toBe('Varrock');
    expect(location!.type).toBe('settlement');
    expect(location!.members).toBe(false);
    expect(location!.region).toBe('Misthalin');
    expect(location!.leagueRegion).toBe('Misthalin');

    expect(location!.relativeLocation).toEqual({
      north: 'Wilderness',
      south: 'Lumbridge',
      east: 'Digsite',
      west: 'Barbarian Village',
    });
  });

  it('parses the Varrock boundary polygon vertices and centroid', () => {
    const page = loadTestPage(TestPages.Varrock);
    const location = parseLocationFromContent(
      page.text,
      page.title,
      page.aliases
    );

    expect(location).not.toBeNull();
    expect(location!.polygon).toBeDefined();
    expect(location!.polygon!.vertices.length).toBe(16);
    expect(location!.polygon!.vertices[0]).toEqual({ x: 3137, y: 3523 });
    expect(location!.polygon!.vertices[1]).toEqual({ x: 3328, y: 3523 });

    // Centroid is within the bounding box of the vertices
    const xs = location!.polygon!.vertices.map((v) => v.x);
    const ys = location!.polygon!.vertices.map((v) => v.y);
    const minX = Math.min(...xs);
    const maxX = Math.max(...xs);
    const minY = Math.min(...ys);
    const maxY = Math.max(...ys);
    const { x, y } = location!.polygon!.centroid;
    expect(x).toBeGreaterThanOrEqual(minX);
    expect(x).toBeLessThanOrEqual(maxX);
    expect(y).toBeGreaterThanOrEqual(minY);
    expect(y).toBeLessThanOrEqual(maxY);
  });

  it('returns null for a page with no location infobox', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    const location = parseLocationFromContent(
      page.text,
      page.title,
      page.aliases
    );
    expect(location).toBeNull();
  });

  it('detects being inside Varrock via the polygon (point-in-polygon)', () => {
    const page = loadTestPage(TestPages.Varrock);
    const location = parseLocationFromContent(
      page.text,
      page.title,
      page.aliases
    );
    const vertices = location!.polygon!.vertices;

    // Standard ray-casting point-in-polygon test
    const inside = (px: number, py: number) => {
      let hit = false;
      for (let i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
        const xi = vertices[i].x;
        const yi = vertices[i].y;
        const xj = vertices[j].x;
        const yj = vertices[j].y;
        if (
          yi > py !== yj > py &&
          px < ((xj - xi) * (py - yi)) / (yj - yi) + xi
        ) {
          hit = !hit;
        }
      }
      return hit;
    };

    // A point in the middle of Varrock is inside the boundary
    expect(inside(3216, 3428)).toBe(true);
    // A point far away (Lumbridge) is outside
    expect(inside(3222, 3218)).toBe(false);
  });
});
