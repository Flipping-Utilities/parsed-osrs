import { parseWikitext } from '../../utils/wikitext-parser';
import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import {
  convertMaterialsToObject,
  parseRecipeProperties,
} from './recipes.extractor';

type RecipeTemplate = Record<string, string>;

const itemIds: Record<string, number> = {
  'A stone bowl#Empty': 2888,
  'A stone bowl#Full': 2889,
  'Copper ore': 436,
  'Tin ore': 438,
  'Nature rune': 561,
  'Fire rune': 554,
  'Bronze bar': 2349,
};

const itemLookup = (name: string): { id: number } | null => {
  const id = itemIds[name];
  if (!id) {
    return null;
  }

  return { id };
};

function extractRecipeTemplates(pageId: number): RecipeTemplate[] {
  const page = loadTestPage(pageId);

  return parseWikitext(page.text).getTemplates('recipe') as RecipeTemplate[];
}

describe('parseRecipeProperties', () => {
  it('parses the real A stone bowl recipe template', () => {
    const [stoneBowlRecipe] = extractRecipeTemplates(TestPages.StoneBowl);

    expect(stoneBowlRecipe).toBeDefined();

    const recipe = parseRecipeProperties(stoneBowlRecipe, itemLookup);

    expect(recipe).not.toBeNull();
    expect(recipe!.members).toBe(true);
    expect(recipe!.ticks).toBeNull();
    expect(recipe!.facility).toBe('Lava trough');
    expect(recipe!.notes).toBe(
      'Requires partial completion of Elemental Workshop I'
    );
    expect(recipe!.inputs).toHaveLength(1);
    expect(recipe!.outputs).toHaveLength(1);
    expect(recipe!.inputs[0].id).toBe(2888);
    expect(recipe!.inputs[0].quantity).toBe(1);
    expect(recipe!.inputs[0].text).toBe('A stone bowl');
    expect(recipe!.outputs[0].id).toBe(2889);
    expect(recipe!.outputs[0].quantity).toBe(1);
    expect(recipe!.outputs[0].text).toBe('A stone bowl');
  });

  it('parses all Bronze bar recipe templates with skills, ticks, and multi-skill', () => {
    const bronzeRecipes = extractRecipeTemplates(TestPages.BronzeBar);

    expect(bronzeRecipes).toHaveLength(3);

    const parsedRecipes = bronzeRecipes
      .map((recipe) => parseRecipeProperties(recipe, itemLookup))
      .filter(
        (recipe): recipe is NonNullable<typeof recipe> => recipe !== null
      );

    expect(parsedRecipes).toHaveLength(3);

    const furnaceRecipe = parsedRecipes.find(
      (recipe) => recipe.facility === 'Furnace'
    );
    expect(furnaceRecipe).toBeDefined();
    if (!furnaceRecipe) {
      throw new Error('Expected Furnace Bronze bar recipe');
    }
    expect(furnaceRecipe!.members).toBe(false);
    expect(furnaceRecipe!.ticks).toBe(5);
    expect(furnaceRecipe!.ticksNote).toBe(
      'Make-X is 4, then 5. A single bar is 6.'
    );
    expect(furnaceRecipe!.skills).toHaveLength(1);
    expect(furnaceRecipe!.skills[0].name).toBe('Smithing');
    expect(furnaceRecipe!.skills[0].lvl).toBe(1);
    expect(furnaceRecipe!.skills[0].xp).toBe(6.2);
    expect(furnaceRecipe!.inputs).toHaveLength(2);
    expect(furnaceRecipe!.inputs.map((input) => input.id)).toEqual([436, 438]);
    expect(furnaceRecipe!.outputs).toHaveLength(1);
    expect(furnaceRecipe!.outputs[0].id).toBe(2349);
    expect(furnaceRecipe!.outputs[0].subText).toBe('Normal furnace');

    const blastRecipe = parsedRecipes.find(
      (recipe) => recipe.facility === 'Blast Furnace'
    );
    expect(blastRecipe).toBeDefined();
    if (!blastRecipe) {
      throw new Error('Expected Blast Furnace Bronze bar recipe');
    }
    expect(blastRecipe!.members).toBe(true);
    expect(blastRecipe!.ticks).toBe(11);
    expect(blastRecipe!.ticksNote).toBe('Multiple bars are completed at once');
    expect(blastRecipe!.skills).toHaveLength(1);
    expect(blastRecipe!.inputs).toHaveLength(2);
    expect(blastRecipe!.outputs[0].subText).toBe('Blast Furnace');

    const superheatRecipe = parsedRecipes.find(
      (recipe) => recipe.skills.length === 2
    );
    expect(superheatRecipe).toBeDefined();
    if (!superheatRecipe) {
      throw new Error('Expected Superheat Bronze bar recipe');
    }
    expect(superheatRecipe!.members).toBe(false);
    expect(superheatRecipe!.ticks).toBe(3);
    expect(superheatRecipe!.skills).toHaveLength(2);
    expect(superheatRecipe!.skills[0].name).toBe('Smithing');
    expect(superheatRecipe!.skills[0].lvl).toBe(1);
    expect(superheatRecipe!.skills[0].boostable).toBe(true);
    expect(superheatRecipe!.skills[1].name).toBe('Magic');
    expect(superheatRecipe!.skills[1].lvl).toBe(43);
    expect(superheatRecipe!.skills[1].boostable).toBe(true);
    expect(superheatRecipe!.skills[1].xp).toBe(53);
    expect(superheatRecipe!.inputs).toHaveLength(4);
    expect(superheatRecipe!.inputs.map((input) => input.id)).toEqual([
      436, 438, 561, 554,
    ]);
    expect(superheatRecipe!.inputs[3].quantity).toBe(4);
    expect(superheatRecipe!.outputs[0].subText).toBe('Superheat');
  });
});

describe('convertMaterialsToObject', () => {
  it('converts real A stone bowl recipe inputs and outputs', () => {
    const [stoneBowlRecipe] = extractRecipeTemplates(TestPages.StoneBowl);

    const inputs = convertMaterialsToObject(stoneBowlRecipe, 'mat', itemLookup);
    const outputs = convertMaterialsToObject(
      stoneBowlRecipe,
      'output',
      itemLookup
    );

    expect(inputs).toHaveLength(1);
    expect(inputs[0].id).toBe(2888);
    expect(inputs[0].quantity).toBe(1);
    expect(inputs[0].text).toBe('A stone bowl');
    expect(inputs[0].cost).toBeUndefined();

    expect(outputs).toHaveLength(1);
    expect(outputs[0].id).toBe(2889);
    expect(outputs[0].quantity).toBe(1);
    expect(outputs[0].text).toBe('A stone bowl');
    expect(outputs[0].cost).toBeUndefined();
  });
});
