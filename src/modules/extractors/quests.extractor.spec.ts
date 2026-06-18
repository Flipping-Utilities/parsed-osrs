import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import { parseQuestFromContent } from './quests.extractor';

describe('parseQuestFromContent', () => {
  it("parses Cook's Assistant details and rewards", () => {
    const page = loadTestPage(TestPages.CooksAssistant);
    const quest = parseQuestFromContent(page.text, page.title, page.aliases);

    expect(quest).not.toBeNull();
    expect(quest!.name).toBe("Cook's Assistant");
    expect(quest!.number).toBe(1);
    expect(quest!.members).toBe(false);
    expect(quest!.series).toBe('None');
    expect(quest!.difficulty).toBe('Novice');
    expect(quest!.length).toBe('Very Short');
    expect(quest!.questPoints).toBe(1);
    expect(quest!.startCoords).toEqual({ x: 3208, y: 3214 });

    // Item requirements are parsed from the bullet list (including nested notes)
    expect(quest!.itemRequirements).toEqual(
      expect.arrayContaining([
        'Egg (can be obtained during the quest)',
        'Bucket of milk',
        'Pot of flour',
      ])
    );
  });

  it('returns null for a page with no quest infobox', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    expect(
      parseQuestFromContent(page.text, page.title, page.aliases)
    ).toBeNull();
  });
});
