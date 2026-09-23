/**
 * Skill-resource identification constants.
 *
 * On the wiki, every page that acts as a skill resource (a tree, a rock, a
 * fishing spot, a pickpocketing target, …) transcludes a per-skill
 * `{{<Skill> info}}` template (e.g. `{{Woodcutting info}}`,
 * `{{Mining info}}`). These templates are the data source behind the wiki's
 * skill experience tables — they carry the skill, required level, XP, tool,
 * and timing, and the resource's drop tables live on the same page as
 * `{{DropsLineSkill|...}}` rows.
 *
 * This registry lets the pipeline identify resource pages purely from the
 * dumped wikitext in the local SQLite DB — no wiki API call needed.
 *
 * The generic `{{Skill info}}` template (used when no per-skill wrapper
 * exists) carries the skill in its `skill1name` parameter, so its canonical
 * skill is resolved per page by the extractor (`null` here).
 *
 * Non-skill `* info` templates ({{Clue info}}, {{Salvage info}},
 * {{Scan clue info}}, …) are deliberately excluded.
 */
export const SKILL_INFO_TEMPLATE_NAMES: Record<string, string | null> = {
  "agility info": "Agility",
  "cooking info": "Cooking",
  "crafting info": "Crafting",
  "divination info": "Divination",
  "dungeoneering info": "Dungeoneering",
  "farming info": "Farming",
  "firemaking info": "Firemaking",
  "fishing info": "Fishing",
  "fletching info": "Fletching",
  "hunter info": "Hunter",
  "invention info": "Invention",
  "mining info": "Mining",
  "necromancy info": "Necromancy",
  "prayer info": "Prayer",
  "runecrafting info": "Runecrafting",
  "skill info": null,
  "smithing info": "Smithing",
  "thieving info": "Thieving",
  "woodcutting info": "Woodcutting",
};

/**
 * Matches any transclusion of a skill info template from
 * {@link SKILL_INFO_TEMPLATE_NAMES}. Template-name alternation is sorted
 * longest-first so e.g. `woodcutting info` is preferred over `skill info`
 * when both could match at the same position.
 */
export const SKILL_INFO_TEMPLATE_PATTERN = new RegExp(
  `\\{\\{\\s*(${Object.keys(SKILL_INFO_TEMPLATE_NAMES)
    .sort((a, b) => b.length - a.length)
    .join("|")})\\s*\\|`,
  "i",
);

/**
 * RS3 wiki markup difference: instead of OSRS's
 * `{{DropsLineSkill|...|skill=<Skill>}}`, RS3 resource pages use
 * skill-suffixed variants like `{{DropsLineWC|...}}` (Woodcutting) or
 * `{{DropsLineThieving|...}}`. Maps canonical skill → wtf-normalised
 * (lowercase) template names, so the drop parser can pull a resource's
 * rows regardless of which convention the page uses.
 */
export const SKILL_DROP_LINE_TEMPLATE_NAMES: Record<string, string[]> = {
  Agility: ["dropslineagility"],
  Crafting: ["dropslinecrafting"],
  Divination: ["dropslinediv"],
  Farming: ["dropslinefarm"],
  Fishing: ["dropslinefish"],
  Fletching: ["dropslinefletching"],
  Herblore: ["dropslineherblore"],
  Hunter: ["dropslinehunt", "dropslinehunter"],
  Mining: ["dropslinemining"],
  Prayer: ["dropslineprayer"],
  Runecrafting: ["dropslinerc"],
  Smithing: ["dropslinesmithing"],
  Summoning: ["dropslinesummoning"],
  Thieving: ["dropslinethieving", "dropslinethiev"],
  Woodcutting: ["dropslinewc"],
};
