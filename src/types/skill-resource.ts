/**
 * A skilling resource page: a tree, a rock, a fishing spot, a pickpocketing
 * target, etc. — any page transcluding a `{{<Skill> info}}` template.
 */
export interface SkillResource {
  /** Resource name — the info template's `name` param, falling back to the page title. */
  name: string;
  /** Canonical skill name, e.g. "Woodcutting" (from the template name or `skill1name`). */
  skill: string;
  aliases: string[];
  /** Required skill level, or null when the page doesn't state one. */
  level: number | null;
  /** Experience per interaction, or null. May be fractional (e.g. 37.5). */
  xp: number | null;
  /** Tool required, e.g. "Axe" — empty string when none stated. */
  tool: string;
  /** Interaction time as written on the wiki, e.g. "~15s". */
  time: string;
  /** Numbered variants (`version1`/`name1`/`level1`/`xp1`/... params). */
  variants: SkillResourceVariant[];
  /** `{{DropsLineSkill}}` rows from the page's drop table(s). */
  drops: SkillResourceDrop[];
}

export interface SkillResourceVariant {
  /** Variant label — `nameN` param, falling back to the `versionN` label. */
  name?: string;
  level?: number;
  xp?: number;
  tool?: string;
  time?: string;
}

export interface SkillResourceDrop {
  name: string;
  itemId: number | null;
  quantity: string;
  /** Wiki rarity, e.g. "Always", "1/4", "Rare". */
  rarity: string;
  /** Alternative rarity, e.g. "32/11008" (with a glory/amulet boost). */
  altRarity: string;
  rarityNotes: string;
}
