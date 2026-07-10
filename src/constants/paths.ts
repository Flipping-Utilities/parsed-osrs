import * as fs from 'fs';
export const DATA_FOLDER = process.env.DATA_FOLDER_PATH || './data';
export const WIKI_DATA_FOLDER = process.env.WIKI_FOLDER_PATH || './wiki-data';

// Wiki content must be on a different path as it's on its own repo
export const WIKI_PAGES_FOLDER = `${WIKI_DATA_FOLDER}/wiki-pages`;
export const WIKI_PAGE_LIST = `${WIKI_PAGES_FOLDER}/wiki-page-list.json`;
export const WIKI_PAGE_LIST_FOLDER = `${WIKI_DATA_FOLDER}/page-lists`;

export const META_FILE = `${DATA_FOLDER}/meta.json`;
export const ITEMS_FOLDER = `${DATA_FOLDER}/items`;
export const MONSTERS_FOLDER = `${DATA_FOLDER}/monsters`;
export const PRAYERS_FOLDER = `${DATA_FOLDER}/prayers`;
export const SPELLS_FOLDER = `${DATA_FOLDER}/spells`;
export const LOCATIONS_FOLDER = `${DATA_FOLDER}/locations`;
export const NPCS_FOLDER = `${DATA_FOLDER}/npcs`;
export const SCENERY_FOLDER = `${DATA_FOLDER}/scenery`;
export const QUESTS_FOLDER = `${DATA_FOLDER}/quests`;
export const ACTIVITIES_FOLDER = `${DATA_FOLDER}/activities`;
export const NEWS_FOLDER = `${DATA_FOLDER}/news`;
export const MUSIC_FOLDER = `${DATA_FOLDER}/music`;
export const MODULES_FOLDER = `${DATA_FOLDER}/modules`;
export const TEMPLATE_FOLDER = `${DATA_FOLDER}/templates`;

fs.mkdirSync(WIKI_PAGES_FOLDER, { recursive: true });
fs.mkdirSync(WIKI_PAGE_LIST_FOLDER, { recursive: true });
fs.mkdirSync(ITEMS_FOLDER, { recursive: true });
fs.mkdirSync(MONSTERS_FOLDER, { recursive: true });
fs.mkdirSync(PRAYERS_FOLDER, { recursive: true });
fs.mkdirSync(SPELLS_FOLDER, { recursive: true });
fs.mkdirSync(LOCATIONS_FOLDER, { recursive: true });
fs.mkdirSync(NPCS_FOLDER, { recursive: true });
fs.mkdirSync(SCENERY_FOLDER, { recursive: true });
fs.mkdirSync(QUESTS_FOLDER, { recursive: true });
fs.mkdirSync(ACTIVITIES_FOLDER, { recursive: true });
fs.mkdirSync(NEWS_FOLDER, { recursive: true });
fs.mkdirSync(MUSIC_FOLDER, { recursive: true });
fs.mkdirSync(MODULES_FOLDER, { recursive: true });
fs.mkdirSync(TEMPLATE_FOLDER, { recursive: true });

export const ALL_SPAWNS = `${ITEMS_FOLDER}/all-spawns.json`;
export const ALL_ITEMS = `${ITEMS_FOLDER}/all-items.json`;
export const ALL_ITEM_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-item-page-list.json`;
export const ALL_ITEM_SPAWNS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-item-spawns-page-list.json`;
export const ALL_SETS = `${ITEMS_FOLDER}/all-sets.json`;
export const ALL_SETS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-sets-page-list.json`;
export const ALL_RECIPES = `${ITEMS_FOLDER}/all-recipes.json`;
export const ALL_RECIPES_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-recipes-page-list.json`;
export const GE_ITEM_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/ge-item-page-list.json`;

export const ALL_SHOPS = `${ITEMS_FOLDER}/all-shops.json`;
export const ALL_SHOPS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-shops-page-list.json`;

export const ALL_MONSTERS = `${MONSTERS_FOLDER}/all-monsters.json`;
export const ALL_MONSTERS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-monsters-page-list.json`;

export const ALL_PRAYERS = `${PRAYERS_FOLDER}/all-prayers.json`;
export const ALL_PRAYERS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-prayers-page-list.json`;

export const ALL_SPELLS = `${SPELLS_FOLDER}/all-spells.json`;
export const ALL_SPELLS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-spells-page-list.json`;

export const ALL_LOCATIONS = `${LOCATIONS_FOLDER}/all-locations.json`;
export const ALL_LOCATIONS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-locations-page-list.json`;

export const ALL_NPCS = `${NPCS_FOLDER}/all-npcs.json`;
export const ALL_NPCS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-npcs-page-list.json`;

export const ALL_SCENERY = `${SCENERY_FOLDER}/all-scenery.json`;
export const ALL_SCENERY_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-scenery-page-list.json`;

export const ALL_QUESTS = `${QUESTS_FOLDER}/all-quests.json`;
export const ALL_QUESTS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-quests-page-list.json`;
export const ALL_QUEST_GUIDES_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-quest-guides-page-list.json`;

export const ALL_ACTIVITIES = `${ACTIVITIES_FOLDER}/all-activities.json`;
export const ALL_ACTIVITIES_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-activities-page-list.json`;

export const ALL_NEWS = `${NEWS_FOLDER}/all-news.json`;
export const ALL_NEWS_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-news-page-list.json`;

export const ALL_MUSIC = `${MUSIC_FOLDER}/all-music.json`;
export const ALL_MUSIC_PAGE_LIST = `${WIKI_PAGE_LIST_FOLDER}/all-music-page-list.json`;
