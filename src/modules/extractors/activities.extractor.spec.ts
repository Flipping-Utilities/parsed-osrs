import { loadTestPage, type TestPage } from "../../../test/test-utils";
import { TestPages } from "../../constants/test-pages";
import { parseActivityFromContent } from "./activities.extractor";

describe("parseActivityFromContent", () => {
  it("parses Tombs of Amascut raid metadata and position", () => {
    const page = loadTestPage(TestPages.TombsOfAmascut);
    const activity = parseActivityFromContent(page.text, page.title, page.aliases);

    expect(activity).not.toBeNull();
    expect(activity!.name).toBe("Tombs of Amascut");
    expect(activity!.type).toBe("Raid");
    expect(activity!.members).toBe(true);
    expect(activity!.location).toBe("Jaltevas Pyramid");
    expect(activity!.players).toBe("1-8");
    expect(activity!.skills).toEqual(["Combat", "Mining"]);
    expect(activity!.leagueRegion).toBe("Desert");
    expect(activity!.position).toEqual({ x: 3345, y: 2725 });
  });

  it("returns null for a page with no activity infobox", () => {
    const page = loadTestPage(TestPages.StoneBowl);
    expect(parseActivityFromContent(page.text, page.title, page.aliases)).toBeNull();
  });
});
