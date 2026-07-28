import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_QUESTS } from "../../constants/paths";
import { MapPoint, Quest, QuickGuideStep, WalkthroughSection } from "../../types";
import { PageContentDumper, PageListDumper } from "../dumpers";
import { PageTags } from "../../constants/tags";
import { parseWikitext } from "../../utils/wikitext-parser";
import { extractTemplate, parseTemplateFields } from "../../utils/brace-utils";
import { wikiBool, wikiNumber, wikiString } from "../../utils/wiki-coercion";
import { DatabaseService } from "../database/database.service";
import { WikiPage } from "../database/schema";
import { eq } from "drizzle-orm";

function parseStartCoords(val: unknown): MapPoint | undefined {
  const m = String(val ?? "").match(/(\d+)[,:](\d+)/);
  return m ? { x: Number(m[1]), y: Number(m[2]) } : undefined;
}

/**
 * Resolves common OSRS wiki inline templates to readable text so that values
 * like `{{SCP|Agility|50|link=yes}} {{Boostable|yes}}` become
 * `"Agility 50 (boostable)"`. {{SCP}} (Skill Crawler Price, but repurposed as
 * a skill-level chip) renders as `Skill level`, {{Boostable}} collapses to a
 * trailing `(boostable)` marker, and {{Chat option|...}} is dropped entirely
 * since dialogue choices add noise to compact step text.
 */
function cleanWikiInline(raw: string): string {
  let s = raw;

  // {{SCP|Skill|Level|link=yes}} → "Skill Level"
  // Also handles {{SCP|Skill}} (just the skill name).
  s = s.replace(/\{\{\s*SCP\s*\|([^}]*?)\}\}/gi, (_m, inner) => {
    const parts = String(inner)
      .split("|")
      .map((p) => p.trim())
      // Drop named params like `link=yes`
      .filter((p) => !/=/.test(p));
    return parts.filter(Boolean).join(" ");
  });

  // {{Boostable|yes}} / {{Boostable}} → "(boostable)"
  s = s.replace(/\{\{\s*Boostable\s*\|?[^}]*\}\}/gi, "(boostable)");

  // {{Chat option|...}} → drop entirely (dialogue noise)
  s = s.replace(/\{\{\s*Chat option\s*\|[^}]*\}\}/gi, "");

  // {{Questreqstart|yes}} / {{Questreqstart|no}} — quest-point requirement
  // marker, not useful in flattened output. Drop.
  s = s.replace(/\{\{\s*Questreqstart\s*\|?[^}]*\}\}/gi, "");

  // {{Fairycode|blr}} → "blr"
  s = s.replace(/\{\{\s*Fairycode\s*\|([^}|]+)[^}]*\}\}/gi, "$1");

  // {{LeagueRegion|Asgarnia}} → "Asgarnia"
  s = s.replace(/\{\{\s*LeagueRegion\s*\|([^}|]+)[^}]*\}\}/gi, "$1");

  // {{RE|Fremennik}} → "Fremennik"
  s = s.replace(/\{\{\s*RE\s*\|([^}|]+)[^}]*\}\}/gi, "$1");

  // {{okay}} / {{colour|...|text}} → strip wrapper, keep text
  s = s.replace(/\{\{\s*okay\s*\}\}/gi, "");
  s = s.replace(/\{\{\s*[Cc]olour\s*\|[^|}]*\|([^}|]+)[^}]*\}\}/g, "$1");

  // {{NoCoins|5}} → "5 coins"
  s = s.replace(/\{\{\s*NoCoins\s*\|(\d+)[^}]*\}\}/gi, "$1 coins");

  // {{FloorNumber|uk=0}} → "ground floor"
  s = s.replace(/\{\{\s*FloorNumber\s*\|\s*uk\s*=\s*0\s*\}\}/gi, "ground floor");
  s = s.replace(/\{\{\s*FloorNumber\s*\|\s*uk\s*=\s*(\d+)\s*\}\}/gi, "floor $1");

  // {{Ironman}} → "(Ironman)"
  s = s.replace(/\{\{\s*Ironman\s*\}\}/gi, "(Ironman)");

  // {{UIMnote|...}} — Ultimate Ironman tip; collapse to nothing (the body is
  // preserved as surrounding text).
  s = s.replace(/\{\{\s*UIMnote\s*\|[^}]*\}\}/gi, "");

  // {{Needed|items|skills=...|recommended=...}} — inline step requirements box.
  // We drop the wrapper but keep the inner item/skill lists as text.
  s = s.replace(/\{\{\s*Needed\s*\|([^}]*)\}\}/gi, (_m, inner) => {
    const parts = String(inner)
      .split("|")
      .map((p) => p.trim())
      .filter((p) => !/^(skills|recommended)\s*=/.test(p));
    return parts.filter(Boolean).join(" ");
  });

  return s;
}

/**
 * Final text cleanup applied AFTER cleanWikiInline + wikiString. Collapses
 * repeated whitespace, trims trailing punctuation noise, and strips leftover
 * template fragments that wtf's generic resolver might leave behind.
 */
function finalClean(s: string): string {
  return s
    .replace(/\s+/g, " ")
    .replace(/\s+([.,;!?])/g, "$1")
    .replace(/\(\s*\)/g, "")
    .trim();
}

/**
 * Parses a multi-line wiki bullet list (`* item`, `** nested`) into a flat
 * array of strings. Each bullet — top-level or nested — becomes its own
 * entry, so nested requirements like the Legends' Quest quest tree don't
 * collapse onto their parent (which would lose all but the first child).
 *
 * Each line is run through cleanWikiInline + wikiString so `[[links]]`,
 * templates and emphasis markup become plain text.
 */
function parseBulletList(val: unknown): string[] {
  if (!val) return [];
  const out: string[] = [];
  for (const line of String(val).split("\n")) {
    const m = line.match(/^\s*\*+\s*(.*)$/);
    if (!m) continue;
    const text = finalClean(wikiString(cleanWikiInline(m[1])));
    if (text) out.push(text);
  }
  return out;
}

/**
 * Parses a single prose block (the body of a walkthrough subsection, or the
 * ironman concerns string). Strips inline templates, file embeds and wiki
 * markup, then collapses whitespace. Image captions embedded as
 * `[[File:...|thumb|caption]]` are dropped along with the file reference.
 */
function parseProse(val: unknown): string {
  if (!val) return "";
  return finalClean(wikiString(cleanWikiInline(String(val))));
}

/**
 * Level-2 sections that are NOT part of the guide body. Everything else
 * between the quest intro and `==Rewards==` is treated as a walkthrough step.
 */
const NON_WALKTHROUGH_SECTIONS = new Set([
  "details",
  "introduction",
  "rewards",
  "required for completing",
  "transcript",
  "trivia",
  "changes",
]);

/**
 * Extracts walkthrough sections from the quest page. Two layouts are
 * supported:
 *
 * 1. **Modern** — a single `==Walkthrough==` H2 wrapping `===subsection===`
 *    H3s (current wiki style for most quests).
 * 2. **Flat / legacy** — each guide step is its own `==Step==` H2 sitting
 *    between `==Details==` / `==Introduction==` and `==Rewards==` (older
 *    dumps and a handful of pages that haven't been migrated).
 *
 * Returns `undefined` when neither layout yields any sections.
 */
function parseWalkthrough(pageText: string): WalkthroughSection[] | undefined {
  const sections = parseLevel3WithinWalkthrough(pageText) || parseLevel2GuideSections(pageText);
  return sections.length ? sections : undefined;
}

function parseLevel3WithinWalkthrough(pageText: string): WalkthroughSection[] | undefined {
  const startMatch = pageText.match(/\n==\s*Walkthrough\s*==\s*\n/i);
  if (!startMatch || startMatch.index === undefined) return undefined;

  const startIdx = startMatch.index + startMatch[0].length;
  const endMatch = pageText.slice(startIdx).match(/\n==\s*[^=].*?==\s*\n/);
  const endIdx = endMatch ? startIdx + endMatch.index! : pageText.length;
  // Prepend a newline so the leading `===heading===` (immediately after
  // `==Walkthrough==\n`) is matched by the `\n===` regex below.
  const body = "\n" + pageText.slice(startIdx, endIdx);

  const out: WalkthroughSection[] = [];
  const headingRe = /\n===\s*([^=][^=]*?)\s*===\s*\n/g;
  let lastHeading: string | null = null;
  let lastStart = 0;
  let m: RegExpExecArray | null;

  while ((m = headingRe.exec(body)) !== null) {
    if (lastHeading !== null) {
      const sectionBody = body.slice(lastStart, m.index);
      const cleaned = parseProse(sectionBody);
      if (cleaned) out.push({ heading: lastHeading, body: cleaned });
    }
    lastHeading = m[1].trim();
    lastStart = headingRe.lastIndex;
  }
  if (lastHeading !== null) {
    const cleaned = parseProse(body.slice(lastStart));
    if (cleaned) out.push({ heading: lastHeading, body: cleaned });
  }

  // No `===` subsections — emit the whole walkthrough body under a generic
  // heading so callers still get the prose.
  if (!out.length && lastHeading === null) {
    const cleaned = parseProse(body);
    if (cleaned) out.push({ heading: "Walkthrough", body: cleaned });
  }

  return out;
}

/**
 * Legacy layout fallback: walks every `==section==` heading and emits those
 * that aren't in {@link NON_WALKTHROUGH_SECTIONS}. Used when the page has no
 * `==Walkthrough==` wrapper (older dumps and a handful of unmigrated pages).
 */
function parseLevel2GuideSections(pageText: string): WalkthroughSection[] {
  const out: WalkthroughSection[] = [];
  const headingRe = /(?:^|\n)==\s*([^=][^=]*?)\s*==\s*\n/g;
  const headings: { name: string; bodyStart: number }[] = [];
  let m: RegExpExecArray | null;
  while ((m = headingRe.exec(pageText)) !== null) {
    headings.push({ name: m[1].trim(), bodyStart: headingRe.lastIndex });
  }
  for (let i = 0; i < headings.length; i++) {
    const lower = headings[i].name.toLowerCase();
    if (NON_WALKTHROUGH_SECTIONS.has(lower)) continue;
    if (/^walkthrough$/i.test(headings[i].name)) continue; // handled by layout 1
    const bodyEnd =
      i + 1 < headings.length
        ? headings[i + 1].bodyStart - headings[i + 1].name.length - 5
        : pageText.length;
    const body = pageText.slice(headings[i].bodyStart, bodyEnd);
    const cleaned = parseProse(body);
    if (cleaned) out.push({ heading: headings[i].name, body: cleaned });
  }
  return out;
}

/**
 * Extracts the bullet list under the `==Required for completing==` heading.
 * Returns an empty array when the section is absent (which is the case for
 * quests that unlock nothing further).
 */
function parseRequiredFor(pageText: string): string[] {
  const startMatch = pageText.match(/\n==\s*Required for completing\s*==\s*\n/i);
  if (!startMatch) return [];

  const startIdx = startMatch.index! + startMatch[0].length;
  const endMatch = pageText.slice(startIdx).match(/\n==\s*[^=].*?==\s*\n/);
  const endIdx = endMatch ? startIdx + endMatch.index! : pageText.length;
  return parseBulletList(pageText.slice(startIdx, endIdx));
}

/**
 * Pulls the `{{Has quick guide}}` marker (present on every quest main page
 * that has a `/Quick guide` subpage) and returns the conventional subpage
 * title used to look the guide up in the DB.
 */
export function buildQuickGuideTitle(questTitle: string): string {
  return `${questTitle}/Quick guide`;
}

/**
 * Parses a `/Quick guide` subpage into structured step groups. The page is
 * laid out as `==Walkthrough==` containing `===section===` headings; each
 * section may be preceded by an italic `''Items needed: ...''` line and is
 * followed by a `{{Checklist|* step1\n* step2}}` template holding the actual
 * bullet steps.
 *
 * Sections without a checklist are still emitted (with an empty `steps`
 * array) so consumers can render the heading stub if desired.
 */
export function parseQuickGuideFromContent(pageText: string): QuickGuideStep[] {
  // Confine parsing to the `==Walkthrough==` region so the rewards and details
  // transclusions at the top of the page aren't mistaken for steps.
  const startMatch = pageText.match(/\n==\s*Walkthrough\s*==\s*\n/i);
  if (!startMatch || startMatch.index === undefined) return [];
  const startIdx = startMatch.index + startMatch[0].length;
  const endMatch = pageText.slice(startIdx).match(/\n==\s*[^=].*?==\s*\n/);
  const endIdx = endMatch ? startIdx + endMatch.index! : pageText.length;
  // Prepend a newline so the leading `===heading===` is matched by `\n===`.
  const body = "\n" + pageText.slice(startIdx, endIdx);

  const steps: QuickGuideStep[] = [];
  const headingRe = /\n===\s*([^=][^=]*?)\s*===\s*\n/g;
  let lastHeading: string | null = null;
  let lastStart = 0;
  let m: RegExpExecArray | null;

  while ((m = headingRe.exec(body)) !== null) {
    if (lastHeading !== null) {
      steps.push(parseQuickGuideSection(lastHeading, body.slice(lastStart, m.index)));
    }
    lastHeading = m[1].trim();
    lastStart = headingRe.lastIndex;
  }
  if (lastHeading !== null) {
    steps.push(parseQuickGuideSection(lastHeading, body.slice(lastStart)));
  }

  return steps;
}

function parseQuickGuideSection(heading: string, chunk: string): QuickGuideStep {
  // Italic `''Items needed: ...''` line OUTSIDE a checklist. Tolerates the
  // unclosed-italic case (some wiki pages open `''` but never close it) by
  // also matching up to a blank line.
  let itemsNeeded: string | undefined;
  const itemsMatch = chunk.match(/\n''([^'\n][^]*?)(?:''|\n\n)/);
  if (itemsMatch) {
    itemsNeeded = finalClean(wikiString(cleanWikiInline(itemsMatch[1])));
  }

  // {{Checklist|...}} body — may contain nested templates, so use brace-utils.
  const checklistBodies = extractTemplate(chunk, "Checklist");
  const steps: string[] = [];
  for (let body of checklistBodies) {
    // The wiki often places the italic "Items needed: ..." line *inside* the
    // checklist body, ahead of the first bullet. Pull it out into itemsNeeded
    // (only when we didn't already find one outside) and strip it from the
    // body so it doesn't leak into the steps array. Tolerates unclosed italic.
    if (!itemsNeeded) {
      const innerItems = body.match(/\n?''([^'\n][^]*?)(?:''|\n\n)/);
      if (innerItems && /^items needed/i.test(innerItems[1].trim())) {
        itemsNeeded = finalClean(wikiString(cleanWikiInline(innerItems[1])));
        body = body.replace(innerItems[0], "\n");
      }
    } else {
      // Already have itemsNeeded from outside the checklist; strip any inner
      // italic blocks so they don't pollute the bullet steps.
      body = body.replace(/\n?''[^'\n][^]*?(?:''|\n\n)/g, "\n");
    }
    steps.push(...parseBulletList(body));
  }

  const step: QuickGuideStep = { section: heading, steps };
  if (itemsNeeded) step.itemsNeeded = itemsNeeded;
  return step;
}

export function parseQuestFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[],
): Quest | null {
  const parsed = parseWikitext(pageText);
  const infobox = parsed.getInfobox("quest");
  if (!infobox) return null;

  // Raw bodies preserve nested templates (e.g. {{SCP|Agility|50|link=yes}})
  // which the registered `quest details` / `quest rewards` templates resolve
  // to '' inside wtf — see wikitext-parser.ts. We re-parse the raw text so
  // requirements / kills / ironman / recommended come through intact.
  const detailsBodies = extractTemplate(pageText, "Quest details");
  const rewardsBodies = extractTemplate(pageText, "Quest rewards");
  const infoboxBodies = extractTemplate(pageText, "Infobox Quest");
  const details = detailsBodies.length ? parseTemplateFields(detailsBodies[0]) : {};
  const rewards = rewardsBodies.length ? parseTemplateFields(rewardsBodies[0]) : {};
  // For `image`, `release`, `update`, `developer` — pull from the raw Infobox
  // Quest body so values like `[[File:Foo.png|300px]]` aren't stripped by
  // wikiString before we can extract the filename.
  const infoboxRaw = infoboxBodies.length ? parseTemplateFields(infoboxBodies[0]) : {};

  const startCoords = parseStartCoords(details.startmap);

  const quest: Quest = {
    name: wikiString(infobox.name) || pageTitle,
    aliases: pageAliases,
    number: wikiNumber(infobox.number),
    members: wikiBool(infobox.members),
    series: wikiString(infobox.series),
    difficulty: wikiString(details.difficulty),
    length: wikiString(details.length),
    start: wikiString(details.start),
    description: wikiString(details.description),
    itemRequirements: parseBulletList(details.items),
    recommendedItems: parseBulletList(details.recommended),
    requirements: parseBulletList(details.requirements),
    enemiesToDefeat: parseBulletList(details.kills),
    questPoints: wikiNumber(rewards.qp),
    rewards: parseBulletList(rewards.rewards),
    requiredFor: parseRequiredFor(pageText),
  };

  if (startCoords) quest.startCoords = startCoords;

  const ironman = parseProse(details.ironman);
  if (ironman) quest.ironmanConcerns = ironman;

  const leagueRegion = parseProse(details.leagueregion);
  if (leagueRegion) quest.leagueRegion = leagueRegion;

  const walkthrough = parseWalkthrough(pageText);
  if (walkthrough) quest.walkthrough = walkthrough;

  // Optional Infobox Quest metadata. The image is stored as
  // `[[File:Foo.png|300px]]`; pull the bare filename out so consumers can
  // rebuild a Special:FilePath URL.
  if (infoboxRaw.image) {
    const fileMatch = String(infoboxRaw.image).match(/\[\[\s*File:\s*([^\]|]+)/i);
    if (fileMatch) quest.image = fileMatch[1].trim();
  }
  if (infoboxRaw.release) quest.release = wikiString(infoboxRaw.release);
  if (infoboxRaw.update) quest.update = wikiString(infoboxRaw.update);
  if (infoboxRaw.developer) quest.developer = wikiString(infoboxRaw.developer);

  return quest;
}

@Injectable()
export class QuestsExtractor {
  private logger = new Logger(QuestsExtractor.name);
  private cachedQuests: Quest[] | null = null;

  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
    private readonly databaseService: DatabaseService,
  ) {}

  public async extractAllQuests(): Promise<Quest[]> {
    this.logger.log("Start: Extracting quests");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.QUEST);
    const length = pages.length;
    const quests: Quest[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 50 === 0) {
        this.logger.debug(`Quests: ${i}/${length}`);
      }
      const quest = await this.extractQuestFromPageId(page.id);
      if (quest) quests.push(quest);
    }

    quests.sort((a, b) => a.number - b.number);
    if (quests.length) {
      writeFileSync(ALL_QUESTS, JSON.stringify(quests, null, 2));
    }

    this.logger.log("Done: Extracting quests");
    return quests;
  }

  public getAllQuests(): Quest[] | null {
    if (!this.cachedQuests) {
      if (!existsSync(ALL_QUESTS)) {
        return null;
      }
      try {
        this.cachedQuests = JSON.parse(readFileSync(ALL_QUESTS, "utf8"));
      } catch (e) {
        this.logger.warn("all quests has invalid content", e);
      }
    }
    return this.cachedQuests;
  }

  private async extractQuestFromPageId(pageId: number): Promise<Quest | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    const quest = parseQuestFromContent(page.text, page.title, page.aliases || []);
    if (!quest) return null;

    // Merge in the matching `/Quick guide` subpage if we have one. The guide
    // shares the quest's title with a `/Quick guide` suffix; look it up
    // directly in the wiki_page table. Missing guides are silent — many
    // mini-quests and older quests don't have one.
    const guideTitle = buildQuickGuideTitle(page.title);
    const guidePage = await this.getDBPageByTitle(guideTitle);
    if (guidePage?.text) {
      const quickGuide = parseQuickGuideFromContent(guidePage.text);
      if (quickGuide.length) quest.quickGuide = quickGuide;
    }

    return quest;
  }

  private async getDBPageByTitle(title: string): Promise<typeof WikiPage.$inferSelect | undefined> {
    const db = this.databaseService.getDb();
    const rows = await db.select().from(WikiPage).where(eq(WikiPage.title, title)).limit(1);
    return rows?.[0];
  }
}
