import { parseMapTemplate } from './map-parser';

describe('parseMapTemplate', () => {
  describe('polygon', () => {
    it('parses integer vertices from a flat x,y,x,y list', () => {
      const result = parseMapTemplate({
        mtype: 'polygon',
        list: ['2663,4089,2659,4089,2656,4086'],
      });

      expect(result?.polygon).toBeDefined();
      expect(result!.polygon!.vertices).toEqual([
        { x: 2663, y: 4089 },
        { x: 2659, y: 4089 },
        { x: 2656, y: 4086 },
      ]);
    });

    // Regression: curved/irregular OSRS wiki polygons use sub-tile decimal
    // coordinates (e.g. 2633.7). The old coordinate regex only matched
    // integers, so "2633.7,4074.3" was scanned as a match on the trailing
    // "7,4074" then ".3,..." — dropping the integer part, doubling the
    // vertex count, and smearing the bounding box (see "Have an Ice Day",
    // cacheId 217). Decimals must round-trip intact.
    it('preserves decimal coordinates without splitting on the decimal point', () => {
      const result = parseMapTemplate({
        mtype: 'polygon',
        list: ['2633.7,4074.3,2633.7,4073.7,2634,4073'],
      });

      expect(result?.polygon).toBeDefined();
      expect(result!.polygon!.vertices).toEqual([
        { x: 2633.7, y: 4074.3 },
        { x: 2633.7, y: 4073.7 },
        { x: 2634, y: 4073 },
      ]);
      // No spurious extra vertices from the fractional digits.
      expect(result!.polygon!.vertices).toHaveLength(3);
    });

    it('keeps the bounding box within the real coordinate range for a decimal polygon', () => {
      // Excerpt of the "Have an Ice Day" boundary (cacheId 217), which mixes
      // integer and decimal vertices. Before the fix this produced x values
      // as low as 2 and y values in the 2600s.
      const result = parseMapTemplate({
        mtype: 'polygon',
        list: [
          '2663,4089,2633.7,4074.3,2624.2,4042.2,2681.5,3988,2665,3978',
        ],
      });

      const xs = result!.polygon!.vertices.map((v) => v.x);
      const ys = result!.polygon!.vertices.map((v) => v.y);
      expect(Math.min(...xs)).toBeGreaterThanOrEqual(2624);
      expect(Math.max(...xs)).toBeLessThanOrEqual(2682);
      expect(Math.min(...ys)).toBeGreaterThanOrEqual(3978);
      expect(Math.max(...ys)).toBeLessThanOrEqual(4089);
    });

    it('parses the x:y,x:y notation with decimals', () => {
      const result = parseMapTemplate({
        mtype: 'polygon',
        list: ['2633.7:4074.3,2681.5:3988'],
      });

      expect(result!.polygon!.vertices).toEqual([
        { x: 2633.7, y: 4074.3 },
        { x: 2681.5, y: 3988 },
      ]);
    });
  });

  describe('point', () => {
    it('prefers explicit x/y named params', () => {
      const result = parseMapTemplate({ mtype: 'pin', x: '2633.7', y: '4074' });
      expect(result?.point).toEqual({ x: 2633.7, y: 4074 });
    });

    it('falls back to the first positional x,y pair, decimals included', () => {
      const result = parseMapTemplate({
        mtype: 'pin',
        list: ['2633.7,4074.3'],
      });
      expect(result?.point).toEqual({ x: 2633.7, y: 4074.3 });
    });
  });
});
