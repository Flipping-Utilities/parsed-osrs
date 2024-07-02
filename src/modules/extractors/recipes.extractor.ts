import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_RECIPES } from '../../constants/paths';
import { Recipe, RecipeMaterial, RecipeSkill, Set } from '../../types';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { ItemsExtractor } from './items.extractor';
import { SetsExtractor } from './sets.extractor';

// @ts-ignore
import * as parse from 'infobox-parser';

type WikiMaterialKey = '' | 'quantity' | 'cost' | 'itemnote' | 'txt' | 'subtxt';
const WikiMaterialKeyToRecipeMaterialKey: Record<
  WikiMaterialKey,
  keyof RecipeMaterial
> = {
  '': 'id',
  quantity: 'quantity',
  cost: 'cost',
  itemnote: 'notes',
  txt: 'text',
  subtxt: 'subText',
};
type WikiSkillKeys = '' | 'lvl' | 'boostable' | 'exp';
const WikiSkillKeyToRecipeSkillKey: Record<WikiSkillKeys, keyof RecipeSkill> = {
  '': 'name',
  boostable: 'boostable',
  exp: 'xp',
  lvl: 'lvl',
};

@Injectable()
export class RecipesExtractor {
  private logger: Logger = new Logger(RecipesExtractor.name);

  private cachedRecipes: Set[] | null = null;

  constructor(
    private itemExtractor: ItemsExtractor,
    private setsExtractor: SetsExtractor,
    private pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper
  ) {}

  public async extractAllRecipes() {
    this.logger.log('Starting to extract recipes');

    const itemPages = this.pageListDumper.getAllItems();
    const recipes = itemPages
      .map((page) => this.extractRecipesFromPageId(page.pageid))
      .filter((v) => v)
      .reduce((acc, r) => {
        acc.push(...r);
        return acc;
      }, [])
      .filter((v) => v);
    // Add all sets
    const sets = this.setsExtractor.getAllSets();
    if (sets) {
      sets
        .filter((s) => s.id)
        .map((set) => {
          const setItem = this.itemExtractor.getItemById(set.id);
          const makeRecipe: Recipe = {
            name: `Making ${setItem?.name || 'Unknown set'}`,
            inputs: set.componentIds.map((v) => ({
              id: v,
              quantity: 1,
            })),
            outputs: [
              {
                id: set.id,
                quantity: 1,
              },
            ],
            skills: [],
            // Todo: Find if set is f2p/p2p
            members: setItem.isMembers || false,
            ticks: 1,
            toolIds: [],
          };
          const breakRecipe: Recipe = {
            outputs: set.componentIds.map((v) => ({
              id: v,
              quantity: 1,
            })),
            inputs: [
              {
                id: set.id,
                quantity: 1,
              },
            ],
            skills: [],
            // Todo: Find if set is f2p/p2p
            members: true,
            ticks: 1,
            toolIds: [],
          };
          return [makeRecipe, breakRecipe];
        })
        .forEach((setRecipes) => {
          recipes.push(...setRecipes);
        });
    }
    if (recipes.length) {
      writeFileSync(ALL_RECIPES, JSON.stringify(recipes, null, 2));
    }

    this.logger.log('End of recipes extraction');
    return recipes;
  }

  public getAllRecipes(): Set[] | null {
    if (!this.cachedRecipes) {
      const candidatePath = ALL_RECIPES;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, 'utf8');
      try {
        this.cachedRecipes = JSON.parse(pageContent);
      } catch (e) {
        this.logger.warn('all recipes has invalid content', e);
      }
    }

    return this.cachedRecipes;
  }

  private extractRecipesFromPageId(pageId: number): Recipe[] | null {
    const page = this.pageContentDumper.getPageFromId(pageId);

    const hasRecipe = page?.rawContent.includes('{{Recipe');
    if (!page || !hasRecipe) {
      // Item has no recipes
      return null;
    }

    const recipesText = page.rawContent
      .split('{{Recipe')
      .map((v) => '{{Recipe' + v)
      // End at the end of the recipe, not at the end of the file.
      .map((v) => v.split('\n}}')[0] + '\n}}');
    // Remove the first one: It's before the first recipe
    recipesText.shift();

    const newRecipes: Recipe[] = recipesText
      .map((text) => this.parseRecipe(text))
      .filter((v) => v) as Recipe[];

    return newRecipes;
  }

  private parseRecipe(recipeText: string): Recipe | null {
    const rawRecipe = parse(recipeText);
    if (!rawRecipe || !rawRecipe.general) {
      console.warn('Could not parse recipe!');
      return null;
    }

    const recipeProperties = rawRecipe.general;

    const skills: RecipeSkill[] = [];
    const skillKeys = Object.keys(recipeProperties).filter((k) =>
      k.startsWith('skill')
    );
    const baseSkill: RecipeSkill = {
      boostable: true,
      lvl: 1,
      name: 'Unknown',
      xp: 0,
    };

    skillKeys.forEach((key) => {
      const withoutSkill = key.split('skill')[1];
      const property = withoutSkill.split(/^\d+/)[1] as WikiSkillKeys;
      const index = Number(withoutSkill.replace(property, '')) - 1;

      if (!skills[index]) {
        skills[index] = { ...baseSkill };
      }
      let value = recipeProperties[key];
      switch (property) {
        case 'lvl':
        case 'exp':
          value = Number(value);
          break;
        case 'boostable':
          value = Boolean(value);
          break;
        case '':
          break;
        default:
          console.warn(`Unknown recipe skill property: ${property}`);
          break;
      }
      // @ts-ignore
      skills[index][WikiSkillKeyToRecipeSkillKey[property]] = value;
    });

    const inputs: RecipeMaterial[] = this.convertMaterialsToObject(
      recipeProperties,
      'mat'
    );
    const outputs: RecipeMaterial[] = this.convertMaterialsToObject(
      recipeProperties,
      'output'
    );

    const ticks = isNaN(Number(recipeProperties.ticks))
      ? null
      : Number(recipeProperties.ticks);

    const recipe: Recipe = {
      inputs,
      outputs,
      members:
        recipeProperties.members === 'Yes' || recipeProperties.members === true,
      skills,
      ticks,
      ticksNote: recipeProperties.ticksnote,
      toolIds: [],
      facility: recipeProperties.facilities,
      name: recipeProperties.name,
      notes: recipeProperties.notes,
    };

    return recipe;
  }

  private convertMaterialsToObject(
    rawRecipe: Record<string, string>,
    prefix: string
  ): RecipeMaterial[] {
    const baseMaterial: RecipeMaterial = {
      id: 0,
      quantity: 1,
    };
    const materials: RecipeMaterial[] = [];
    const materialKeys = Object.keys(rawRecipe).filter((k) =>
      k.startsWith(prefix)
    );

    materialKeys.forEach((key) => {
      const withoutMat = key.split(prefix)[1];
      const property = withoutMat.split(/^\d+/)[1] as WikiMaterialKey;
      const index = Number(withoutMat.replace(property, '')) - 1;

      if (!materials[index]) {
        materials[index] = { ...baseMaterial };
      }
      let value: any = rawRecipe[key];
      switch (property) {
        case '':
          const id =
            value === 'Coins'
              ? 995
              : this.itemExtractor.getItemByName(value)?.id;
          if (!id) {
            console.warn(`Recipe uses an unknown item: ${value}`);
            return;
          }
          value = id;
          break;
        case 'quantity':
        case 'cost':
          const nb = Number(value);
          // Ignore default strings
          if (!isNaN(nb)) {
            value = nb;
          } else {
            value = baseMaterial[WikiMaterialKeyToRecipeMaterialKey[property]];
          }
          break;
        case 'itemnote':
        case 'txt':
        case 'subtxt':
          // Keep string
          break;
        default:
          console.warn(`Unknown recipe material property: ${property}!`);
          // Skip this recipe component: it's not a known property
          return;
      }
      // @ts-ignore
      materials[index][WikiMaterialKeyToRecipeMaterialKey[property]] = value;
    });

    return materials;
  }
}
