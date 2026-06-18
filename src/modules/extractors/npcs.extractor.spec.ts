import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import { parseNpcFromContent } from './npcs.extractor';

describe('parseNpcFromContent', () => {
  it('parses Hans with id, race, options, and map position', () => {
    const page = loadTestPage(TestPages.Hans);
    const npcs = parseNpcFromContent(page.text, page.title, page.aliases);

    expect(npcs).toHaveLength(1);
    const hans = npcs[0];
    expect(hans.id).toBe(3105);
    expect(hans.name).toBe('Hans');
    expect(hans.members).toBe(false);
    expect(hans.race).toBe('Human');
    expect(hans.location).toBe('Lumbridge');
    expect(hans.gender).toBe('Male');
    expect(hans.options).toEqual(['Talk-to', 'Age']);
    expect(hans.examine).toBe('Servant of the Duke of Lumbridge.');
    expect(hans.leagueRegion).toBe('Misthalin');
    expect(hans.position).toEqual({ x: 3212, y: 3219 });
  });

  it('returns empty array for a page with no NPC infobox', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    expect(parseNpcFromContent(page.text, page.title, page.aliases)).toEqual(
      []
    );
  });
});
