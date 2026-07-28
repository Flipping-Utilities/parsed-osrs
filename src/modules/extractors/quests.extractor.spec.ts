import { loadTestPage, type TestPage } from "../../../test/test-utils";
import { TestPages } from "../../constants/test-pages";
import {
  buildQuickGuideTitle,
  parseQuestFromContent,
  parseQuickGuideFromContent,
} from "./quests.extractor";

describe("parseQuestFromContent", () => {
  it("parses Cook's Assistant details, recommended items and required-for", () => {
    const page = loadTestPage(TestPages.CooksAssistant);
    const quest = parseQuestFromContent(page.text, page.title, page.aliases);

    expect(quest).not.toBeNull();
    expect(quest!.name).toBe("Cook's Assistant");
    expect(quest!.number).toBe(1);
    expect(quest!.members).toBe(false);
    expect(quest!.series).toBe("None");
    expect(quest!.difficulty).toBe("Novice");
    expect(quest!.length).toBe("Very Short");
    expect(quest!.questPoints).toBe(1);
    expect(quest!.startCoords).toEqual({ x: 3208, y: 3214 });

    // Items required to start (Pot, Bucket) — current wiki page lists these as
    // the minimum, with the cake ingredients under `recommended`.
    expect(quest!.itemRequirements).toEqual(expect.arrayContaining(["Pot", "Bucket"]));

    // `recommended` field is now extracted — this is what the wiki moved the
    // cake ingredients into.
    expect(quest!.recommendedItems).toEqual(
      expect.arrayContaining(["Egg", "Bucket of milk", "Pot of flour"]),
    );

    // Cook's Assistant has no skill / quest / combat requirements.
    expect(quest!.requirements).toEqual([]);
    expect(quest!.enemiesToDefeat).toEqual([]);

    // Rewards — {{SCP|Cooking|300|link=yes}} should resolve to "Cooking 300"
    // rather than disappearing (the lossy old behaviour).
    expect(quest!.rewards).toEqual(
      expect.arrayContaining(["Cooking 300 experience", expect.stringContaining("Cook-o-matic")]),
    );

    // `==Required for completing==` bullets.
    expect(quest!.requiredFor).toEqual(
      expect.arrayContaining(["Recipe for Disaster", expect.stringContaining("Easy Lumbridge")]),
    );

    // Walkthrough section is present with at least the two prose subsections
    // (A feast for a Duke, Delivery).
    expect(quest!.walkthrough).toBeDefined();
    expect(quest!.walkthrough!.length).toBeGreaterThanOrEqual(2);
    const headings = quest!.walkthrough!.map((s) => s.heading);
    expect(headings).toEqual(expect.arrayContaining(["A feast for a Duke", "Delivery"]));

    // Infobox Quest optional metadata.
    expect(quest!.developer).toBe("Paul Gower");
    expect(quest!.release).toBe("4 January 2001");
    expect(quest!.image).toBe("Cook's Assistant.png");
  });

  it("parses Legends' Quest skill requirements, kills, and ironman concerns", () => {
    const page = loadTestPage(TestPages.LegendsQuest);
    const quest = parseQuestFromContent(page.text, page.title, page.aliases);

    expect(quest).not.toBeNull();
    expect(quest!.name).toBe("Legends' Quest");
    expect(quest!.number).toBe(50);
    expect(quest!.members).toBe(true);
    expect(quest!.difficulty).toBe("Master");
    expect(quest!.length).toBe("Long");
    expect(quest!.questPoints).toBe(4);

    // `{{SCP|Agility|50|link=yes}} {{Boostable|yes}}` → "Agility 50 (boostable)"
    // Nested `**` quest-tree bullets are emitted as their own entries rather
    // than collapsing onto the parent (so Heroes' Quest, Shield of Arrav,
    // etc. all survive).
    expect(quest!.requirements).toEqual(
      expect.arrayContaining([
        "Agility 50 (boostable)",
        "Mining 52 (boostable)",
        "Magic 56 (boostable)",
        "Herblore 45 (boostable)",
        "Woodcutting 50 (boostable)",
        "Strength 50 (boostable)",
        "Smithing 50 (boostable)",
        "Crafting 50 (boostable)",
        "Thieving 50 (boostable)",
        "Prayer 42 (boostable)",
        "Quest 107",
        "Completion of the following quests:",
        "Family Crest",
        expect.stringMatching(/Heroes['\u2019] Quest/),
        "Shield of Arrav",
        "Lost City",
        "Waterfall Quest",
        "Underground Pass",
        "Biohazard",
        "Plague City",
        "Shilo Village",
        "Jungle Potion",
        "Druidic Ritual",
        expect.stringMatching(/Merlin['\u2019]s Crystal/),
        expect.stringMatching(/Dragon Slayer I/),
        "The ability to defeat a level 187 demon",
      ]),
    );

    // `kills` field — enemies to defeat.
    expect(quest!.enemiesToDefeat).toEqual(
      expect.arrayContaining([
        expect.stringContaining("Ranalph Devere"),
        expect.stringContaining("Irvig Senay"),
        expect.stringContaining("San Tojalon"),
        expect.stringContaining("Nezikchened"),
      ]),
    );

    // `recommended` carries a combat level + super restore potion.
    expect(quest!.recommendedItems.some((s) => /Combat 65/.test(s))).toBe(true);

    // Walkthrough sections — Legends' Quest has many subsections. The wiki
    // dump uses the legacy flat layout (each step is its own `==H2==`) rather
    // than the modern `==Walkthrough==` wrapper with `===H3===` children —
    // both layouts are handled by parseWalkthrough.
    expect(quest!.walkthrough).toBeDefined();
    expect(quest!.walkthrough!.length).toBeGreaterThan(5);
    const headings = quest!.walkthrough!.map((s) => s.heading);
    expect(headings).toEqual(
      expect.arrayContaining([
        "Mapping the jungle",
        "Binding book",
        "Gold bowl",
        "Pure water",
        "The final battle",
      ]),
    );

    // Required-for section.
    expect(quest!.requiredFor).toEqual(
      expect.arrayContaining(["Dragon Slayer II", expect.stringContaining("Recipe for Disaster")]),
    );

    // Rewards — QP plus access unlocks, all parsed without losing the {{SCP}}
    // experience chip.
    expect(quest!.rewards.some((r) => /Legends' Guild/.test(r))).toBe(true);
    expect(quest!.rewards.some((r) => /30,000 experience/.test(r))).toBe(true);
  });

  it("returns null for a page with no quest infobox", () => {
    const page = loadTestPage(TestPages.StoneBowl);
    expect(parseQuestFromContent(page.text, page.title, page.aliases)).toBeNull();
  });
});

describe("parseQuickGuideFromContent", () => {
  it("parses Legends' Quest /Quick guide into ordered step groups with checklists", () => {
    const page = loadTestPage(TestPages.LegendsQuestQuickGuide);
    const guide = parseQuickGuideFromContent(page.text);

    expect(guide.length).toBeGreaterThan(4);
    const sections = guide.map((g) => g.section);
    expect(sections).toEqual(
      expect.arrayContaining([
        "Radimus Erkle",
        "Kharazi Jungle",
        "Fighting Nezikchened",
        "Finishing up",
      ]),
    );

    // The "Sacred pool" section carries an italic `Items needed: ...` line.
    const sacredPool = guide.find((g) => g.section === "Sacred pool");
    expect(sacredPool).toBeDefined();
    expect(sacredPool!.itemsNeeded).toMatch(/Radimus notes/);
    expect(sacredPool!.steps.length).toBeGreaterThan(2);

    // The first section should mention talking to the Legends' Guard.
    const first = guide[0];
    expect(first.steps.some((s) => /Legends' Guard/.test(s))).toBe(true);

    // Chat-option noise should be stripped from steps.
    expect(guide.every((g) => g.steps.every((s) => !/Chat option/i.test(s)))).toBe(true);
  });

  it("returns [] for a page without a Walkthrough section", () => {
    const page = loadTestPage(TestPages.StoneBowl);
    expect(parseQuickGuideFromContent(page.text)).toEqual([]);
  });
});

describe("buildQuickGuideTitle", () => {
  it("appends the conventional /Quick guide suffix", () => {
    expect(buildQuickGuideTitle("Cook's Assistant")).toBe("Cook's Assistant/Quick guide");
    expect(buildQuickGuideTitle("Legends' Quest")).toBe("Legends' Quest/Quick guide");
  });
});
