import wtf from 'wtf_wikipedia';

/**
 * Result of parsing wikitext with OSRS-specific template support.
 */
export interface WikitextParserResult {
  /** Get first infobox matching type (e.g., 'item', 'bonuses'). Returns keyValue() or null. */
  getInfobox(type: string): Record<string, string> | null;
  /** Get all templates matching name (lowercase). Returns array of json() objects. */
  getTemplates(name: string): Array<Record<string, unknown>>;
  /** Check if a template exists on the page. */
  hasTemplate(name: string): boolean;
  /** Get all infoboxes as { type, data } objects. */
  getAllInfoboxes(): Array<{ type: string; data: Record<string, string> }>;
  /** Raw wtf Document for advanced usage. */
  readonly doc: ReturnType<typeof wtf>;
}

/** Type for wtf template parse function */
type TemplateParseFunction = (
  tmpl: string,
  list: Array<Record<string, unknown>>,
  parse: (tmpl: string, keys: string[]) => Record<string, unknown>
) => string;

/** Module-level guard to ensure templates are registered only once */
let osrsTemplatesInitialized = false;

/**
 * Registers OSRS-specific templates with wtf_wikipedia.
 * Called automatically by parseWikitext() - safe to call multiple times.
 */
function initOsrTemplates(): void {
  if (osrsTemplatesInitialized) return;
  osrsTemplatesInitialized = true;

  wtf.extend((models, templates) => {
    // {{sic}} - Marker for intentional errors, should not appear in output
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).sic = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['text']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{SCP|id}} - Street Crawler Price template, returns the id value
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).scp = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['id']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{DropsLine}} - Monster drop table line
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).dropsline = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['name', 'rarity', 'quantity', 'raritynotes']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{DropsLineClue}} - Clue scroll drop line (same fields as DropsLine)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).dropslineclue = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['name', 'rarity', 'quantity', 'raritynotes']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{DropsTableHead}} - Drop table header, just remove from text
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).dropstablehead = '';

    // {{CostLine}} - Cost table line
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).costline = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['item', 'cost']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{StoreLine}} - Store inventory line (generic param parsing)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).storeline = ((tmpl, list, parse): string => {
      // Parse with empty array to capture all params (positional and named)
      const obj = parse(tmpl, []);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{StoreTableHead}} - Store table header (generic param parsing)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).storetablehead = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, []);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{ItemSpawnLine}} - Item spawn location line (generic param parsing)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).itemspawnline = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, []);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{RareDropTable|rdtRarity|gdtRarity|naturetalisman=yes|chaostalisman=yes|rolls=N}}
    // Combined Rare + Gem drop table reference on monster pages
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).raredroptable = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['rdtRarity', 'gdtRarity', 'rolls']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{GemDropTable|gdtRarity|naturetalisman=yes|chaostalisman=yes|rolls=N}}
    // Standalone Gem drop table reference
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).gemdroptable = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['gdtRarity', 'rolls']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{HerbDropLines|rarity|quantity|rolls=N}} - Herb drop table lines
    // wtf normalizes HerbDropLines → herbdroplines (no 's' in drop)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).herbdroplines = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['rarity', 'quantity', 'rolls']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{RareSeedDropLines|rarity|rolls=N}} - Rare seed drop table lines
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).rareseeddroplines = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['rarity', 'rolls']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{DropsLineSkill|name|quantity|rarity|skill}} - Skilling drop line
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).dropslineskill = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['name', 'rarity', 'quantity', 'skill']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{DropsLineReward|name|quantity|rarity}} - Reward drop line
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).dropslinereward = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['name', 'rarity', 'quantity']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{DropsLineEcumenical}} - Ecumenical key drop (no required params)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).dropslineecumenical = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, []);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{WildernessSlayerDropTable|combat|hitpoints|...}} - Wilderness slayer drops
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).wildernessslayerdroptable = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['combat', 'hitpoints', 'combatmax', 'hitpointsmax', 'boss', 'superior']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{WildernessSlayerCaveDropTable|rate}} - Wilderness slayer cave drops
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).wildernessslayercavedroptable = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['1']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{CatacombsDropTable|hitpoints|...}} - Catacombs of Kourend drops
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).catacombsdroptable = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['hitpoints', 'hitpointsmax', 'superior']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{SuperiorDropTable|slayerlevel}} - Superior slayer monster drops
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).superiordroptable = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['1']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{BirdNestDropTable|rate}} - Bird nest drops
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).birdnestdroptable = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['1', 'multiplier', 'rolls']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{FossilDropLines|fossil|numulite}} - Fossil island drops
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).fossildroplines = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['fossil', 'numulite', 'skill', 'access']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{GeneralSeedDropLines|rarity|combatLevel}} - General seed drops
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).generalseeddroplines = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['rarity', 'combatLevel', 'f2p', 'rolls']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{AllotmentSeedDropLines|rarity}} - Allotment seed drops
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).allotmentseeddroplines = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['rarity', 'rolls']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{TalismanDropLines|rarity}} - Talisman drops
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).talismandroplines = ((tmpl, list, parse): string => {
      const obj = parse(tmpl, ['rarity']);
      list.push(obj);
      return '';
    }) as TemplateParseFunction;

    // {{DropsTableBottom}} - Drop table footer
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (templates as any).dropstablebottom = '';
  });
}

/**
 * Parse wikitext with OSRS-specific template support.
 *
 * @param text - Raw wikitext markup
 * @returns WikitextParserResult with convenience methods for accessing infoboxes and templates
 */
export function parseWikitext(text: string): WikitextParserResult {
  initOsrTemplates();

  const doc = wtf(text);

  return {
    getInfobox(type: string): Record<string, string> | null {
      const infoboxes = doc.infoboxes();
      const infobox = infoboxes.find((ib) => ib.type() === type);
      return infobox ? (infobox.keyValue() as Record<string, string>) : null;
    },

    getTemplates(name: string): Array<Record<string, unknown>> {
      const normalizedName = name.toLowerCase();
      return doc
        .templates()
        .map((t) => t.json() as Record<string, unknown>)
        .filter((t) => {
          const templateName = (
            t.template as string | undefined
          )?.toLowerCase();
          return templateName === normalizedName;
        });
    },

    hasTemplate(name: string): boolean {
      const normalizedName = name.toLowerCase();
      return doc.templates().some((t) => {
        const json = t.json() as Record<string, unknown>;
        const templateName = (
          json.template as string | undefined
        )?.toLowerCase();
        return templateName === normalizedName;
      });
    },

    getAllInfoboxes(): Array<{ type: string; data: Record<string, string> }> {
      return doc.infoboxes().map((ib) => ({
        type: ib.type(),
        data: ib.keyValue() as Record<string, string>,
      }));
    },

    get doc() {
      return doc;
    },
  };
}
