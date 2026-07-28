import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_MONSTERS } from "../../constants/paths";
import { DropTable, Monster, MonsterDrop, MonsterLocation } from "../../types";
import { PageContentDumper, PageListDumper } from "../dumpers";
import { ItemsExtractor } from "./items.extractor";
import { PageTags } from "../../constants/tags";
import { parseWikitext } from "../../utils/wikitext-parser";
import { parseListValue, wikiBool, wikiNumber, wikiString } from "../../utils/wiki-coercion";
import { expandDropTables } from "../../data/drop-tables";

const DROP_ROW_TEMPLATES = [
  "dropsline",
  "dropslineclue",
  "dropslineskill",
  "dropslinereward",
  "dropslineecumenical",
] as const;

function collectDropRowTemplates(
  parsed: ReturnType<typeof parseWikitext>,
): Array<Record<string, unknown>> {
  const all: Array<Record<string, unknown>> = [];
  for (const name of DROP_ROW_TEMPLATES) {
    all.push(...parsed.getTemplates(name));
  }
  return all;
}

function collectDropTables(parsed: ReturnType<typeof parseWikitext>): DropTable[] {
  const tables: DropTable[] = [];

  for (const rdt of parsed.getTemplates("raredroptable")) {
    tables.push({
      type: "rare_drop_table",
      rarity: String(rdt.rdtRarity ?? ""),
      rolls: rdt.rolls ? String(rdt.rolls) : undefined,
      chaosTalisman: rdt.chaostalisman === "yes",
      natureTalisman: rdt.naturetalisman === "yes",
    });
    if (rdt.gdtRarity) {
      tables.push({
        type: "gem_drop_table",
        rarity: String(rdt.gdtRarity),
        rolls: rdt.rolls ? String(rdt.rolls) : undefined,
        chaosTalisman: rdt.chaostalisman === "yes",
        natureTalisman: rdt.naturetalisman === "yes",
      });
    }
  }

  for (const gdt of parsed.getTemplates("gemdroptable")) {
    if (!tables.some((t) => t.type === "gem_drop_table")) {
      tables.push({
        type: "gem_drop_table",
        rarity: String(gdt.gdtRarity ?? ""),
        rolls: gdt.rolls ? String(gdt.rolls) : undefined,
        chaosTalisman: gdt.chaostalisman === "yes",
        natureTalisman: gdt.naturetalisman === "yes",
      });
    }
  }

  for (const herb of parsed.getTemplates("herbdroplines")) {
    tables.push({
      type: "herb_drop_table",
      rarity: String(herb.rarity ?? ""),
      rolls: herb.rolls ? String(herb.rolls) : undefined,
    });
  }

  for (const seed of parsed.getTemplates("rareseeddroplines")) {
    tables.push({
      type: "rare_seed_drop_table",
      rarity: String(seed.rarity ?? ""),
      rolls: seed.rolls ? String(seed.rolls) : undefined,
    });
  }

  for (const ws of parsed.getTemplates("wildernessslayerdroptable")) {
    tables.push({
      type: "wilderness_slayer_table",
      combat: String(ws.combat ?? ws["1"] ?? ""),
      hitpoints: String(ws.hitpoints ?? ws["2"] ?? ""),
      boss: ws.boss === "yes",
      superior: ws.superior === "yes",
    });
  }

  for (const wsc of parsed.getTemplates("wildernessslayercavedroptable")) {
    tables.push({
      type: "wilderness_slayer_cave_table",
      rarity: String(wsc["1"] ?? wsc.rarity ?? ""),
    });
  }

  for (const cat of parsed.getTemplates("catacombsdroptable")) {
    tables.push({
      type: "catacombs_table",
      hitpoints: String(cat.hitpoints ?? cat["1"] ?? ""),
      superior: cat.superior === "yes",
    });
  }

  for (const sup of parsed.getTemplates("superiordroptable")) {
    tables.push({
      type: "superior_table",
      rarity: String(sup["1"] ?? ""),
    });
  }

  for (const bn of parsed.getTemplates("birdnestdroptable")) {
    tables.push({
      type: "bird_nest_table",
      rarity: String(bn["1"] ?? bn.rarity ?? ""),
      rolls: bn.rolls ? String(bn.rolls) : undefined,
    });
  }

  for (const fossil of parsed.getTemplates("fossildroplines")) {
    tables.push({
      type: "fossil_table",
      rarity: String(fossil.access ?? fossil["1"] ?? ""),
    });
  }

  return tables;
}

function parsePoisonous(val: unknown): string | boolean {
  const lower = String(val ?? "")
    .toLowerCase()
    .trim();
  if (lower === "yes" || val === true) return true;
  if (lower === "no" || val === false) return false;
  return wikiString(val);
}

function parseImmunity(val: unknown): boolean {
  if (!val) return false;
  const lower = String(val).toLowerCase().trim();
  if (lower === "not immune") return false;
  if (lower === "immune") return true;
  return wikiBool(val);
}

/**
 * Parses {{LocLine}} location blocks from raw monster page wikitext.
 * Uses regex directly (rather than the wtf parser) because coordinate params
 * use colon-prefixed keys (e.g. `|x:2657,y:3341`) that don't map cleanly to
 * named template parameters. Each non-coordinate field lives on its own line.
 */
function parseMonsterLocations(pageText: string): MonsterLocation[] {
  const locations: MonsterLocation[] = [];
  const blockRe = /\{\{LocLine\b([\s\S]*?)\}\}/gi;
  let blockMatch: RegExpExecArray | null;
  while ((blockMatch = blockRe.exec(pageText)) !== null) {
    const block = blockMatch[1];
    const getField = (name: string): string => {
      const m = block.match(new RegExp(`^\\s*\\|\\s*${name}\\s*=\\s*(.*?)\\s*$`, "mi"));
      return m ? m[1].trim() : "";
    };

    const coordinates: Array<{ x: number; y: number }> = [];
    const coordRe = /x:(\d+),y:(\d+)/g;
    let coordMatch: RegExpExecArray | null;
    while ((coordMatch = coordRe.exec(block)) !== null) {
      coordinates.push({ x: Number(coordMatch[1]), y: Number(coordMatch[2]) });
    }

    const mtype = getField("mtype");
    locations.push({
      name: wikiString(getField("name")),
      location: wikiString(getField("location")),
      levels: getField("levels"),
      members: wikiBool(getField("members")),
      mapId: wikiNumber(getField("mapID")),
      ...(mtype && { mtype }),
      coordinates,
    });
  }
  return locations;
}

const wikiToMonsterKeyMap: Record<string, keyof Monster> = {
  id: "id",
  name: "name",
  combat: "combatLevel",
  hitpoints: "hitpoints",
  att: "attackLevel",
  str: "strengthLevel",
  def: "defenceLevel",
  mage: "magicLevel",
  range: "rangedLevel",
  "attack speed": "attackSpeed",
  "attack style": "attackStyle",
  "max hit": "maxHit",
  size: "size",
  aggressive: "aggressive",
  poisonous: "poisonous",
  attributes: "attributes",
  elementalweaknesstype: "elementalWeaknessType",
  elementalweaknesspercent: "elementalWeaknessPercent",
  attbns: "attackBonus",
  strbns: "strengthBonus",
  amagic: "magicAttackBonus",
  mbns: "magicDamageBonus",
  arange: "rangedAttackBonus",
  rngbns: "rangedStrengthBonus",
  dstab: "stabDefence",
  dslash: "slashDefence",
  dcrush: "crushDefence",
  dmagic: "magicDefence",
  dlight: "lightRangedDefence",
  dstandard: "standardRangedDefence",
  dheavy: "heavyRangedDefence",
  flatarmour: "flatArmour",
  xpbonus: "xpBonus",
  members: "isMembers",
  slaylvl: "slayerLevel",
  slayxp: "slayerXp",
  cat: "slayerCategory",
  assignedby: "assignedBy",
  immunepoison: "immuneToPoison",
  immunevenom: "immuneToVenom",
  immunecannon: "immuneToCannon",
  immunethrall: "immuneToThrall",
  immuneburn: "immuneToBurn",
  freezeresistance: "freezeResistance",
  examine: "examine",
};

function wikiToMonsterKey(baseKey: string): keyof Monster | null {
  return wikiToMonsterKeyMap[baseKey] ?? null;
}

export function parseMonsterFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[],
  itemLookup: (name: string) => { id: number } | null,
): Monster[] {
  const parsed = parseWikitext(pageText);
  const monsterData = parsed.getInfobox("monster");
  if (!monsterData) return [];

  const hasMultiple = Object.keys(monsterData).some((v) => v.endsWith("2"));

  const dropTemplates = collectDropRowTemplates(parsed);

  const drops: MonsterDrop[] = dropTemplates
    .map((t) => {
      const name = String(t.name ?? "");
      const itemId = itemLookup(name)?.id ?? null;
      return {
        name,
        itemId,
        quantity: String(t.quantity ?? ""),
        rarity: String(t.rarity ?? ""),
      };
    })
    .filter((d) => d.name);

  const dropTables = collectDropTables(parsed);

  const locations = parseMonsterLocations(pageText);

  const herbTemplate = parsed.getTemplates("herbdroplines")[0];
  const herbQuantity = herbTemplate?.quantity ? String(herbTemplate.quantity) : undefined;
  const expandedDrops = expandDropTables(dropTables, herbQuantity);

  const subTableDrops: MonsterDrop[] = expandedDrops.map((d) => ({
    name: d.name,
    itemId: itemLookup(d.name)?.id ?? null,
    quantity: String(d.quantity),
    rarity: d.rarity,
  }));

  const expandedNames = new Set(subTableDrops.map((d) => d.name));
  const uniqueDrops = drops.filter((d) => !expandedNames.has(d.name));
  const allDrops = [...uniqueDrops, ...subTableDrops];

  const baseMonster: Monster = {
    id: 0,
    name: pageTitle,
    aliases: pageAliases,
    combatLevel: wikiNumber(monsterData.combat),
    hitpoints: wikiNumber(monsterData.hitpoints),
    attackLevel: wikiNumber(monsterData.att),
    strengthLevel: wikiNumber(monsterData.str),
    defenceLevel: wikiNumber(monsterData.def),
    magicLevel: wikiNumber(monsterData.mage),
    rangedLevel: wikiNumber(monsterData.range),
    attackSpeed: wikiNumber(monsterData["attack speed"]),
    attackStyle: wikiString(monsterData["attack style"]),
    maxHit: wikiString(monsterData["max hit"]),
    size: wikiNumber(monsterData.size),
    aggressive: wikiBool(monsterData.aggressive),
    poisonous: parsePoisonous(monsterData.poisonous),
    attributes: wikiString(monsterData.attributes),
    elementalWeaknessType: wikiString(monsterData.elementalweaknesstype),
    elementalWeaknessPercent: wikiNumber(monsterData.elementalweaknesspercent),
    attackBonus: wikiNumber(monsterData.attbns),
    strengthBonus: wikiNumber(monsterData.strbns),
    magicAttackBonus: wikiNumber(monsterData.amagic),
    magicDamageBonus: wikiNumber(monsterData.mbns),
    rangedAttackBonus: wikiNumber(monsterData.arange),
    rangedStrengthBonus: wikiNumber(monsterData.rngbns),
    stabDefence: wikiNumber(monsterData.dstab),
    slashDefence: wikiNumber(monsterData.dslash),
    crushDefence: wikiNumber(monsterData.dcrush),
    magicDefence: wikiNumber(monsterData.dmagic),
    lightRangedDefence: wikiNumber(monsterData.dlight),
    standardRangedDefence: wikiNumber(monsterData.dstandard),
    heavyRangedDefence: wikiNumber(monsterData.dheavy),
    flatArmour: wikiNumber(monsterData.flatarmour),
    xpBonus: wikiNumber(monsterData.xpbonus),
    isMembers: wikiBool(monsterData.members),
    slayerLevel: wikiNumber(monsterData.slaylvl),
    slayerXp: wikiNumber(monsterData.slayxp),
    slayerCategory: wikiString(monsterData.cat),
    assignedBy: parseListValue(monsterData.assignedby),
    immuneToPoison: parseImmunity(monsterData.immunepoison),
    immuneToVenom: parseImmunity(monsterData.immunevenom),
    immuneToCannon: wikiBool(monsterData.immunecannon),
    immuneToThrall: wikiBool(monsterData.immunethrall),
    immuneToBurn: wikiString(monsterData.immuneburn),
    freezeResistance: wikiNumber(monsterData.freezeresistance),
    drops: allDrops,
    dropTables,
    locations,
    examine: monsterData.examine ?? "",
  };

  const candidateMonsters: Monster[] = [];

  if (hasMultiple) {
    let allVariants: Monster[] = [];
    Object.keys(monsterData).forEach((key: string) => {
      const candidateKey = key.match(/\d+$/);
      const endIndex = candidateKey ? Number(candidateKey[0]) : 0;
      const baseKey = key.replace(/\d+$/, "");
      if (key === baseKey || endIndex === 0) return;

      if (!allVariants[endIndex]) {
        allVariants[endIndex] = { ...baseMonster };
      }

      let value: unknown;
      switch (baseKey) {
        // Numeric fields
        case "id":
        case "combat":
        case "hitpoints":
        case "att":
        case "str":
        case "def":
        case "mage":
        case "range":
        case "attbns":
        case "strbns":
        case "amagic":
        case "mbns":
        case "arange":
        case "rngbns":
        case "dstab":
        case "dslash":
        case "dcrush":
        case "dmagic":
        case "dlight":
        case "dstandard":
        case "dheavy":
        case "flatarmour":
        case "xpbonus":
        case "slaylvl":
        case "slayxp":
        case "freezeresistance":
        case "elementalweaknesspercent":
          value = wikiNumber(monsterData[key]);
          break;
        // String fields (wikiString)
        case "examine":
        case "attack style":
        case "max hit":
        case "attributes":
        case "elementalweaknesstype":
        case "immuneburn":
        case "cat":
          value = wikiString(monsterData[key]);
          break;
        // Boolean fields (wikiBool)
        case "aggressive":
        case "members":
        case "immunecannon":
        case "immunethrall":
          value = wikiBool(monsterData[key]);
          break;
        // Immunity fields (parseImmunity)
        case "immunepoison":
        case "immunevenom":
          value = parseImmunity(monsterData[key]);
          break;
        // Poisonous field (parsePoisonous)
        case "poisonous":
          value = parsePoisonous(monsterData[key]);
          break;
        // List fields (parseListValue)
        case "assignedby":
          value = parseListValue(monsterData[key]);
          break;
        // Name — keep raw string
        case "name":
          value = String(monsterData[key] ?? "");
          break;
        default:
          break;
      }

      const fieldName = wikiToMonsterKey(baseKey);
      if (value !== undefined && value !== "" && fieldName) {
        (allVariants[endIndex] as unknown as Record<string, unknown>)[fieldName] = value;
      }
    });

    allVariants = allVariants.filter((v) => v.id);
    candidateMonsters.push(...allVariants);
  } else {
    const monsterId = wikiNumber(monsterData.id);
    if (monsterId) {
      baseMonster.id = monsterId;
      candidateMonsters.push(baseMonster);
    }
  }

  return candidateMonsters;
}

@Injectable()
export class MonstersExtractor {
  private logger: Logger = new Logger(MonstersExtractor.name);

  private cachedMonsters: Monster[] | null = null;

  constructor(
    private itemExtractor: ItemsExtractor,
    private pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
  ) {}

  public async extractAllMonsters() {
    this.logger.log("Start: Extracting monsters");

    const monstersPage = await this.pageListDumper.getPagesFromTag(PageTags.MONSTER);
    const length = monstersPage.length;
    const monsters: Monster[] = [];
    let i = 0;
    for await (const page of monstersPage) {
      if (i++ % 100 === 0) {
        this.logger.debug(`Monsters: ${i}/${length}`);
      }
      const monstersFromPage = await this.extractMonsterFromPageId(page.id);
      monsters.push(...monstersFromPage);
    }

    if (monsters.length) {
      writeFileSync(ALL_MONSTERS, JSON.stringify(monsters));
    }

    this.logger.log("Done: Extracting monsters");
    return monsters;
  }

  public getAllMonsters(): Monster[] | null {
    if (!this.cachedMonsters) {
      const candidatePath = ALL_MONSTERS;
      if (!existsSync(candidatePath)) {
        return null;
      }

      const pageContent = readFileSync(candidatePath, "utf8");
      let parsed = null;
      try {
        parsed = JSON.parse(pageContent);
      } catch (e) {
        this.logger.log("all monsters has invalid content", e);
      }
      this.cachedMonsters = parsed;
    }

    return this.cachedMonsters;
  }

  private async extractMonsterFromPageId(pageId: number): Promise<Monster[]> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page) {
      this.logger.warn("Could not fetch page content from id", pageId);
      return [];
    }

    const lookup = (name: string) => this.itemExtractor.getItemByName(name);

    if (!page.text) {
      this.logger.warn("No text for monster", page.title, page.id);
      return [];
    }

    const monsters = parseMonsterFromContent(page.text, page.title, page.aliases || [], lookup);
    if (!monsters.length) {
      this.logger.warn("no id for monster", page.title, page.id);
    }
    return monsters;
  }
}
