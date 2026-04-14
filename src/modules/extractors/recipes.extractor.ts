import { Injectable, Logger } from '@nestjs/common';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { ALL_RECIPES } from '../../constants/paths';
import { PageTags } from '../../constants/tags';
import { Recipe, RecipeMaterial, RecipeSkill, Set } from '../../types';
import { wikiBool, wikiNumber } from '../../utils/wiki-coercion';
import { parseWikitext } from '../../utils/wikitext-parser';
import { PageContentDumper, PageListDumper } from '../dumpers';
import { ItemsExtractor } from './items.extractor';
import { SetsExtractor } from './sets.extractor';

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

export function convertMaterialsToObject(
  rawRecipe: Record<string, string>,
  prefix: string,
  itemLookup: (name: string) => { id: number } | null
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
        const id = value === 'Coins' ? 995 : itemLookup(value)?.id;
        if (!id) {
          return;
        }
        value = id;
        break;
      case 'quantity':
      case 'cost':
        const nb = wikiNumber(value);
        // Ignore default strings
        if (nb !== 0) {
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
        return;
    }
    // @ts-ignore
    materials[index][WikiMaterialKeyToRecipeMaterialKey[property]] = value;
  });

  return materials;
}

export function parseRecipeProperties(
  recipeProperties: Record<string, string | boolean>,
  itemLookup: (name: string) => { id: number } | null
): Recipe | null {
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
    let value: string | number | boolean = recipeProperties[key] as string;
    switch (property) {
      case 'lvl':
      case 'exp':
        value = wikiNumber(value, 1);
        break;
      case 'boostable':
        value = wikiBool(value);
        break;
      case '':
        break;
      default:
        break;
    }
    // @ts-ignore
    skills[index][WikiSkillKeyToRecipeSkillKey[property]] = value;
  });

  const inputs: RecipeMaterial[] = convertMaterialsToObject(
    recipeProperties as Record<string, string>,
    'mat',
    itemLookup
  );
  const outputs: RecipeMaterial[] = convertMaterialsToObject(
    recipeProperties as Record<string, string>,
    'output',
    itemLookup
  );

  const ticks = wikiNumber(recipeProperties.ticks, 0) || null;
  let toolIds: number[] = [];
  if (recipeProperties.tools) {
    toolIds = recipeProperties.tools
      .toString()
      .split(',')
      .map((v) => {
        const item = itemLookup(v);
        return item?.id;
      })
      .filter((v): v is number => v !== undefined);
  }
  const recipe: Recipe = {
    inputs,
    outputs,
    members: wikiBool(recipeProperties.members),
    skills,
    ticks,
    ticksNote: recipeProperties.ticksnote as string,
    toolIds,
    facility: recipeProperties.facilities as string,
    name: recipeProperties.name as string,
    notes: recipeProperties.notes as string,
  };

  return recipe;
}

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

    const itemPages = await this.pageListDumper.getPagesFromTag(PageTags.ITEM);
    if (!itemPages) {
      return;
    }
    const recipes: Recipe[] = [];
    for await (const page of itemPages) {
      const pageRecipes = await this.extractRecipesFromPageId(page.id);
      if (pageRecipes === null) {
        continue;
      }
      recipes.push(...pageRecipes);
    }

    // Add all sets
    const sets = await this.setsExtractor.getAllSets();
    if (sets !== null) {
      sets!
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
            members: setItem?.isMembers || false,
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
      recipes.sort((a, b) => a?.name?.localeCompare(b.name || '') || 0);
      writeFileSync(ALL_RECIPES, JSON.stringify(recipes));
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

  private async extractRecipesFromPageId(
    pageId: number
  ): Promise<Recipe[] | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);

    const hasRecipe = page?.text?.includes('{{Recipe');
    if (!page || !hasRecipe) {
      this.logger.verbose(`No recipe for page ${pageId}`);
      return null;
    }

    const text = page.text!;
    const tfPage = parseWikitext(text);
    const recipes: Record<string, string | boolean>[] = tfPage
      .getTemplates('recipe')
      .map((t) => t as Record<string, string | boolean>)
      .filter((t) => Object.hasOwn(t, 'template') && t?.template === 'recipe');

    this.logger.verbose(
      `Parsing ${recipes.length} recipes on page ${page.title}`
    );
    const newRecipes: Recipe[] = recipes
      .map((value) =>
        parseRecipeProperties(value, (name) =>
          this.itemExtractor.getItemByName(name)
        )
      )
      .filter((v) => v) as Recipe[];

    return newRecipes;
  }
}
