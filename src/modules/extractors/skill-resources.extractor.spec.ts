import { loadTestPage, type TestPage } from "../../../test/test-utils";
import { TestPages } from "../../constants/test-pages";
import { parseSkillResourceFromContent } from "./skill-resources.extractor";

const noItemLookup = () => null;

describe("parseSkillResourceFromContent", () => {
  it("identifies the Oak tree as a Woodcutting resource with its skilling drops", () => {
    const page: TestPage = loadTestPage(TestPages.OakTree);
    const resources = parseSkillResourceFromContent(
      page.text,
      page.title,
      page.aliases,
      noItemLookup,
    );

    expect(resources.length).toBe(1);
    const oak = resources[0];
    expect(oak.skill).toBe("Woodcutting");
    expect(oak.name).toBe("Oak tree");
    expect(oak.level).toBe(15);
    expect(oak.xp).toBe(37.5);
    expect(oak.aliases).toContain("Oak trees");

    const logs = oak.drops.find((d) => d.name === "Oak logs");
    expect(logs).toBeDefined();
    expect(logs!.rarity).toBe("Always");
    expect(logs!.quantity).toBe("1");

    const leaves = oak.drops.find((d) => d.name === "Oak leaves");
    expect(leaves).toBeDefined();
    expect(leaves!.rarity).toBe("1/4");

    // Only the two Always/1/4 rows carry the Woodcutting skill param; rows
    // for other skills (none on this revision) would be filtered out.
    expect(oak.drops.length).toBe(2);
  });

  it("captures alternative rarities on gem rolls (Copper rocks)", () => {
    const page: TestPage = loadTestPage(TestPages.CopperRocks);
    const resources = parseSkillResourceFromContent(
      page.text,
      page.title,
      page.aliases,
      noItemLookup,
    );

    expect(resources.length).toBe(1);
    const copper = resources[0];
    expect(copper.skill).toBe("Mining");
    expect(copper.level).toBe(1);

    const sapphire = copper.drops.find((d) => d.name === "Uncut sapphire");
    expect(sapphire).toBeDefined();
    expect(sapphire!.rarity).toBe("32/32768");
    expect(sapphire!.altRarity).toBe("32/11008");

    const nothing = copper.drops.find((d) => d.name === "Nothing");
    expect(nothing).toBeDefined();
    expect(nothing!.rarity).toBe("70/32768");
  });

  it("resolves the skill of a generic {{Skill info}} template from skill1name", () => {
    const text = [
      "{{Skill info",
      "|name = Weird object",
      "|skill1name = Agility",
      "|skill1lvl = 5",
      "|skill1exp = 10",
      "}}",
    ].join("\n");

    const resources = parseSkillResourceFromContent(text, "Weird object", [], noItemLookup);
    expect(resources.length).toBe(1);
    expect(resources[0].skill).toBe("Agility");
    expect(resources[0].level).toBe(5);
    expect(resources[0].xp).toBe(10);
  });

  it("returns an empty array for a page with no skill info template", () => {
    const text = "{{Infobox Item\n|name = Bronze bar\n}}";
    expect(parseSkillResourceFromContent(text, "Bronze bar", [], noItemLookup)).toEqual([]);
  });

  it("skips generic {{Skill info}} rows that carry no skill1name", () => {
    const text = "{{Skill info\n|name = Mysterious\n|level = 1\n}}";
    expect(parseSkillResourceFromContent(text, "Mysterious", [], noItemLookup)).toEqual([]);
  });

  it("keeps only drop rows matching the resource's skill when a page mixes skills", () => {
    const text = [
      "{{Woodcutting info",
      "|name = Magical tree",
      "|level = 75",
      "|xp = 95",
      "}}",
      "{{DropsTableHead}}",
      "{{DropsLineSkill|name=Magic logs|quantity=1|rarity=Always|skill=Woodcutting}}",
      "{{DropsLineSkill|name=Raw shark|quantity=1|rarity=Always|skill=Fishing}}",
      "{{DropsLineSkill|name=Bird nest|quantity=1|rarity=Rare}}",
      "{{DropsTableBottom}}",
    ].join("\n");

    const resources = parseSkillResourceFromContent(text, "Magical tree", [], noItemLookup);
    expect(resources.length).toBe(1);
    const names = resources[0].drops.map((d) => d.name);
    expect(names).toContain("Magic logs");
    expect(names).toContain("Bird nest"); // no skill param → page's skill
    expect(names).not.toContain("Raw shark");
  });

  it("reads RS3 skill-suffixed drop lines ({{DropsLineWC}})", () => {
    const text = [
      "{{Woodcutting info",
      "|name = Acadia tree",
      "|level = 35",
      "|xp = 85",
      "}}",
      "{{DropsTableHead}}",
      "{{DropsLineWC|name=Acadia logs|quantity=1|rarity=Always}}",
      "{{DropsTableBottom}}",
    ].join("\n");

    const resources = parseSkillResourceFromContent(text, "Acadia tree", [], noItemLookup);
    expect(resources.length).toBe(1);
    const names = resources[0].drops.map((d) => d.name);
    expect(names).toEqual(["Acadia logs"]);
  });
});
