import { loadTestPage, type TestPage } from "../../../test/test-utils";
import { TestPages } from "../../constants/test-pages";
import { parseSpellFromContent } from "./spells.extractor";

describe("parseSpellFromContent", () => {
  const runeLookup = (name: string) => {
    const runes: Record<string, { id: number }> = {
      "Air rune": { id: 556 },
      "Mind rune": { id: 558 },
      "Nature rune": { id: 561 },
      "Fire rune": { id: 554 },
    };
    return runes[name] ?? null;
  };

  it("parses Wind Strike combat spell with rune costs", () => {
    const page = loadTestPage(TestPages.WindStrike);

    const spell = parseSpellFromContent(page.text, page.title, page.aliases, runeLookup);

    expect(spell).not.toBeNull();
    expect(spell!.name).toBe("Wind Strike");
    expect(spell!.level).toBe(1);
    expect(spell!.spellbook).toBe("Normal");
    expect(spell!.type).toBe("Combat");
    expect(spell!.exp).toBe(5.5);
    expect(spell!.members).toBe(false);
    expect(spell!.element).toBe("Air");
    expect(spell!.speed).toBe(5);

    expect(spell!.runeCost).toHaveLength(2);
    expect(spell!.runeCost).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ itemId: 556, quantity: 1 }),
        expect.objectContaining({ itemId: 558, quantity: 1 }),
      ]),
    );
  });

  it("returns null for a page with no spell infobox", () => {
    const nonSpellPage = loadTestPage(TestPages.StoneBowl);
    const spell = parseSpellFromContent(
      nonSpellPage.text,
      nonSpellPage.title,
      nonSpellPage.aliases,
      runeLookup,
    );
    expect(spell).toBeNull();
  });

  it("leaves itemId null when the rune is not in the lookup", () => {
    const page = loadTestPage(TestPages.WindStrike);
    const emptyLookup = () => null;

    const spell = parseSpellFromContent(page.text, page.title, page.aliases, emptyLookup);

    expect(spell).not.toBeNull();
    expect(spell!.runeCost).toHaveLength(2);
    expect(spell!.runeCost.every((r) => r.itemId === null)).toBe(true);
  });
});
