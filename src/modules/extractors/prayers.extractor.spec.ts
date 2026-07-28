import { loadTestPage, type TestPage } from "../../../test/test-utils";
import { TestPages } from "../../constants/test-pages";
import { parsePrayerFromContent } from "./prayers.extractor";

describe("parsePrayerFromContent", () => {
  it("parses Ultimate Strength from real fixture data", () => {
    const page = loadTestPage(TestPages.UltimateStrength);

    const prayer = parsePrayerFromContent(page.text, page.title, page.aliases);

    expect(prayer).not.toBeNull();
    expect(prayer!.name).toBe("Ultimate Strength");
    expect(prayer!.level).toBe(31);
    expect(prayer!.drain).toBe(20);
    expect(prayer!.members).toBe(false);
    expect(prayer!.effect).toContain("Increases your strength by 15%");
  });

  it("returns null for a page with no prayer infobox", () => {
    const nonPrayerPage = loadTestPage(TestPages.StoneBowl);
    const prayer = parsePrayerFromContent(
      nonPrayerPage.text,
      nonPrayerPage.title,
      nonPrayerPage.aliases,
    );
    expect(prayer).toBeNull();
  });

  it("falls back to page title when name is absent", () => {
    const page = loadTestPage(TestPages.UltimateStrength);
    const text = page.text.replace("|name = Ultimate Strength", "");

    const prayer = parsePrayerFromContent(text, "Fallback Title", []);

    expect(prayer).not.toBeNull();
    expect(prayer!.name).toBe("Fallback Title");
  });
});
