import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import { parseSceneryFromContent } from './scenery.extractor';

describe('parseSceneryFromContent', () => {
  it('parses the Furnace into one variant per version with an object id', () => {
    const page = loadTestPage(TestPages.Furnace);
    const scenery = parseSceneryFromContent(
      page.text,
      page.title,
      page.aliases
    );

    // The Furnace page lists 24 versions; variants without an id are dropped.
    expect(scenery.length).toBeGreaterThan(15);

    const lumbridge = scenery.find((s) => s.id === 2030);
    expect(lumbridge).toBeDefined();
    expect(lumbridge!.name).toBe('Furnace');
    expect(lumbridge!.ids).toEqual([2030, 6189, 6190, 16657, 24009]);
    expect(lumbridge!.options).toEqual(['Smelt']);
    expect(lumbridge!.members).toBeNull(); // "Some"
    expect(lumbridge!.location).toContain('Lumbridge');
  });

  it('returns empty array for a page with no scenery infobox', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    expect(
      parseSceneryFromContent(page.text, page.title, page.aliases)
    ).toEqual([]);
  });
});
