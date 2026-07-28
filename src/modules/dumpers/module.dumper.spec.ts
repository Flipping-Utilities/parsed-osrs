import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from "fs";
import path from "path";
import { beforeEach, afterEach, describe, expect, it, vi } from "vitest";

// vi.mock factories are hoisted above all top-level statements, so any value
// they close over must itself be hoisted. We can't use the `path` import
// inside the hoisted callback (it hasn't been initialized yet), so plain
// string concatenation it is.
const { TEST_DIR, TEST_MODULES_FOLDER } = vi.hoisted(() => {
  // __dirname here points at src/modules/dumpers/. Go up three segments to
  // the package root, then into test/.tmp-module-dumper/modules.
  const root = __dirname.split(/[\\/]/).slice(0, -3).join("/");
  const testDir = `${root}/test/.tmp-module-dumper`;
  return {
    TEST_DIR: testDir,
    TEST_MODULES_FOLDER: `${testDir}/modules`,
  };
});

// Mock MODULES_FOLDER before module.dumper.ts is imported. Only MODULES_FOLDER
// is exposed because that is the only path symbol this dumper (and therefore
// this test) cares about; loading the real paths.ts would eagerly mkdir a pile
// of dev folders under the cwd.
vi.mock("../../constants/paths", () => ({
  MODULES_FOLDER: TEST_MODULES_FOLDER,
}));

import { ModuleDumper, sanitizeModuleFilename } from "./module.dumper";
import type { WikiRequestService, WikiPageWithContent } from "../wiki/wikiRequest.service";

// Shape returned by WikiRequestService.queryPagesByIds.
function makePage(opts: {
  pageid: number;
  title: string;
  revid?: number;
  content?: string;
}): WikiPageWithContent {
  const title = opts.title;
  return {
    pageid: opts.pageid,
    pagename: title,
    title,
    displaytitle: title,
    revid: opts.revid ?? 1,
    rawContent: opts.content ?? "",
    content: "",
    properties: [],
    redirects: [],
  };
}

// Build a mock WikiRequestService that records every call. Tests assert on
// call counts to prove the batched path is taken and the per-module path
// (`getRawText`) is not.
function makeMockWikiService() {
  return {
    queryAllPagesPromise: vi.fn(),
    queryPagesByIds: vi.fn(),
    getRawText: vi.fn(),
  };
}

describe("ModuleDumper", () => {
  let wiki: ReturnType<typeof makeMockWikiService>;

  beforeEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
    mkdirSync(TEST_MODULES_FOLDER, { recursive: true });
    wiki = makeMockWikiService();
  });

  afterEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
  });

  describe("dumpAllModules — equivalence with old per-module approach", () => {
    it("writes the same on-disk files the old getRawText loop would have written", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: "Module:Foo", ns: 828 },
        { pageid: 2, title: "Module:Bar/sub", ns: 828 },
        { pageid: 3, title: "Module:GELimits/data.json", ns: 828 },
        { pageid: 4, title: "Module:Has Space", ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({ pageid: 1, title: "Module:Foo", content: "foo-source" }),
        makePage({
          pageid: 2,
          title: "Module:Bar/sub",
          content: "bar-sub-source",
        }),
        makePage({
          pageid: 3,
          title: "Module:GELimits/data.json",
          content: "return { ... }",
        }),
        makePage({
          pageid: 4,
          title: "Module:Has Space",
          content: "with-space",
        }),
      ]);

      await dumper.dumpAllModules();

      // The OLD toFilePath() strips "Module:", replaces "/" with "__".
      // Module namespace pages are always Lua → all files get `.lua`.
      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Foo.lua"), "utf8")).toBe("foo-source");
      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Bar__sub.lua"), "utf8")).toBe(
        "bar-sub-source",
      );
      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "GELimits__data.json.lua"), "utf8")).toBe(
        "return { ... }",
      );
      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Has Space.lua"), "utf8")).toBe(
        "with-space",
      );
    });
  });

  describe("dumpAllModules — batching (50x fewer requests)", () => {
    it("never calls getRawText; only batched queryPagesByIds", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      const moduleList = Array.from({ length: 110 }, (_, i) => ({
        pageid: 1000 + i,
        title: `Module:Test${i}`,
        ns: 828,
      }));
      wiki.queryAllPagesPromise.mockResolvedValue(moduleList);
      wiki.queryPagesByIds.mockImplementation(async (ids: number[]) =>
        ids.map((id) =>
          makePage({
            pageid: id,
            title: `Module:Test${id - 1000}`,
            content: `src-${id}`,
          }),
        ),
      );

      await dumper.dumpAllModules();

      expect(wiki.getRawText).not.toHaveBeenCalled();
      // 110 modules / 50-per-batch = 3 calls
      expect(wiki.queryPagesByIds).toHaveBeenCalledTimes(3);
    });

    it("chunks at the MediaWiki hard cap of 50 pageids per request", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      const moduleList = Array.from({ length: 250 }, (_, i) => ({
        pageid: i,
        title: `Module:M${i}`,
        ns: 828,
      }));
      wiki.queryAllPagesPromise.mockResolvedValue(moduleList);
      wiki.queryPagesByIds.mockImplementation(async (ids: number[]) =>
        ids.map((id) => makePage({ pageid: id, title: `Module:M${id}`, content: `s-${id}` })),
      );

      await dumper.dumpAllModules();

      // 250 / 50 = exactly 5 batches
      expect(wiki.queryPagesByIds).toHaveBeenCalledTimes(5);
      for (const call of wiki.queryPagesByIds.mock.calls) {
        expect(call[0].length).toBeLessThanOrEqual(50);
      }
    });

    it("handles an empty module list without issuing any requests", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([]);

      await dumper.dumpAllModules();

      expect(wiki.queryPagesByIds).not.toHaveBeenCalled();
      expect(wiki.getRawText).not.toHaveBeenCalled();
    });
  });

  describe("dumpAllModules — delta skip (only write changed modules)", () => {
    it("does not rewrite files when the revid is unchanged since the previous run", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: "Module:Stable", ns: 828 },
        { pageid: 2, title: "Module:Changed", ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:Stable",
          revid: 100,
          content: "stable-v1",
        }),
        makePage({
          pageid: 2,
          title: "Module:Changed",
          revid: 200,
          content: "changed-v1",
        }),
      ]);

      await dumper.dumpAllModules();

      // Tamper with the on-disk "Stable" file. If the second run re-writes
      // unchanged modules, this tampering would be overwritten.
      writeFileSync(path.join(TEST_MODULES_FOLDER, "Stable.lua"), "TAMPERED-SHOULD-PERSIST");

      // Second run: Stable unchanged, Changed bumped
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:Stable",
          revid: 100,
          content: "stable-v1",
        }),
        makePage({
          pageid: 2,
          title: "Module:Changed",
          revid: 201,
          content: "changed-v2",
        }),
      ]);

      await dumper.dumpAllModules();

      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Stable.lua"), "utf8")).toBe(
        "TAMPERED-SHOULD-PERSIST",
      );
      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Changed.lua"), "utf8")).toBe(
        "changed-v2",
      );
    });

    it("still re-writes a module when its revid changes back to a previously-seen value", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([{ pageid: 1, title: "Module:Revert", ns: 828 }]);

      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:Revert",
          revid: 50,
          content: "rev-50",
        }),
      ]);
      await dumper.dumpAllModules();

      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:Revert",
          revid: 51,
          content: "rev-51",
        }),
      ]);
      await dumper.dumpAllModules();

      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:Revert",
          revid: 50,
          content: "rev-50-restored",
        }),
      ]);
      await dumper.dumpAllModules();

      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Revert.lua"), "utf8")).toBe(
        "rev-50-restored",
      );
    });
  });

  describe("dumpAllModules — edge cases preserved from old behavior", () => {
    it("skips modules whose fetched source is empty (matches old null/empty skip)", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: "Module:HasContent", ns: 828 },
        { pageid: 2, title: "Module:Empty", ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:HasContent",
          content: "real source",
        }),
        makePage({ pageid: 2, title: "Module:Empty", content: "" }),
      ]);

      await dumper.dumpAllModules();

      const files = readdirSync(TEST_MODULES_FOLDER).filter((f) => !f.startsWith("."));
      expect(files).toEqual(["HasContent.lua"]);
    });

    it("silently ignores pageids that no longer exist (missing in API response)", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: "Module:Alive", ns: 828 },
        { pageid: 2, title: "Module:Deleted", ns: 828 },
      ]);
      // Real queryPagesByIds drops missing/invalid pages from its result.
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:Alive",
          content: "alive-source",
        }),
      ]);

      await dumper.dumpAllModules();

      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Alive.lua"), "utf8")).toBe("alive-source");
      expect(existsSync(path.join(TEST_MODULES_FOLDER, "Deleted.lua"))).toBe(false);
    });

    it("preserves the subpage naming convention (slashes → __)", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: "Module:Deep/nested/page", ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:Deep/nested/page",
          content: "deep",
        }),
      ]);

      await dumper.dumpAllModules();

      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Deep__nested__page.lua"), "utf8")).toBe(
        "deep",
      );
    });
  });

  describe("dumpAllModules — index persistence across processes", () => {
    it("persists a revision index that a fresh dumper instance reads on the next run", async () => {
      // First "process": dump the module, expect the index to be written.
      const firstDumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: "Module:Persist", ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:Persist",
          revid: 42,
          content: "persisted",
        }),
      ]);
      await firstDumper.dumpAllModules();

      // Plant a sentinel value on disk; a correctly-skipped second run will
      // NOT overwrite it.
      writeFileSync(path.join(TEST_MODULES_FOLDER, "Persist.lua"), "PRE-RUN-VALUE");

      // Second "process": brand-new instance, same mocks, same revid → skip.
      const secondDumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: "Module:Persist",
          revid: 42,
          content: "SHOULD-NOT-WRITE",
        }),
      ]);
      await secondDumper.dumpAllModules();

      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Persist.lua"), "utf8")).toBe(
        "PRE-RUN-VALUE",
      );
    });
  });

  describe("dumpAllModules — crash resistance", () => {
    it("continues dumping after a write failure instead of aborting the batch", async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: "Module:Good", ns: 828 },
        { pageid: 2, title: "Module:Bad", ns: 828 },
        { pageid: 3, title: "Module:AlsoGood", ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({ pageid: 1, title: "Module:Good", content: "good-1" }),
        makePage({ pageid: 2, title: "Module:Bad", content: "bad" }),
        makePage({
          pageid: 3,
          title: "Module:AlsoGood",
          content: "good-3",
        }),
      ]);

      // Pre-create `Bad.lua` as a directory so writeFileSync('...Bad.lua', source)
      // fails with EISDIR — a natural write failure on every OS, no fs
      // mocking required. The production trigger was an ENOENT from a
      // Windows-reserved `:` in the filename, but any write error exercises
      // the same try/catch.
      mkdirSync(path.join(TEST_MODULES_FOLDER, "Bad.lua"));

      // Must NOT throw — the failure is caught and the dump continues.
      await dumper.dumpAllModules();

      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "Good.lua"), "utf8")).toBe("good-1");
      expect(readFileSync(path.join(TEST_MODULES_FOLDER, "AlsoGood.lua"), "utf8")).toBe("good-3");
    });
  });
});

describe("sanitizeModuleFilename", () => {
  it("strips the Module: namespace prefix and appends .lua", () => {
    expect(sanitizeModuleFilename("Module:Foo")).toBe("Foo.lua");
  });

  it("replaces forward slashes with __ (subpage flattening)", () => {
    expect(sanitizeModuleFilename("Module:Foo/Bar/Baz")).toBe("Foo__Bar__Baz.lua");
  });

  it("replaces colons with _ (Windows-reserved)", () => {
    expect(sanitizeModuleFilename("Module:User:Spoiledduc")).toBe("User_Spoiledduc.lua");
  });

  it("handles the exact title from the production crash", () => {
    // This title produced an ENOENT on Windows because the sanitized name
    // still contained `:` characters from the User: namespace.
    const title = "Module:Sandbox/User:Spoiledduc/Skill calc/AgilityBarb";
    const result = sanitizeModuleFilename(title);
    // No reserved characters should remain (other than the `.lua` extension).
    expect(result).not.toMatch(/[:<>"|?*]/);
    expect(result).toBe("Sandbox__User_Spoiledduc__Skill calc__AgilityBarb.lua");
  });

  it("handles a title with a double Module: prefix", () => {
    // Module:Module:Sandbox → strip first prefix → Module:Sandbox → : → _
    expect(sanitizeModuleFilename("Module:Module:Sandbox")).toBe("Module_Sandbox.lua");
  });

  it("replaces all Windows-reserved characters", () => {
    const title = 'Module:A<B>C"D|E?F*G';
    const result = sanitizeModuleFilename(title);
    expect(result).toBe("A_B_C_D_E_F_G.lua");
  });

  it("replaces backslashes with __", () => {
    expect(sanitizeModuleFilename("Module:Foo\\Bar")).toBe("Foo__Bar.lua");
  });

  it("removes ../ traversal sequences", () => {
    // The `../` sequence is stripped first, then remaining `/` → `__`.
    expect(sanitizeModuleFilename("Module:../etc/passwd")).toBe("etc__passwd.lua");
    expect(sanitizeModuleFilename("Module:../etc/../passwd")).toBe("etc__passwd.lua");
  });

  it("preserves spaces and dots", () => {
    expect(sanitizeModuleFilename("Module:GELimits/data.json")).toBe("GELimits__data.json.lua");
    expect(sanitizeModuleFilename("Module:Has Space")).toBe("Has Space.lua");
  });

  it("strips trailing dots and whitespace before appending .lua (Win32-API normalisation)", () => {
    // Module:Exchange/Premade blurb' sp. — the trailing `.` was preserved by
    // Node's fs but invisible to git/cmd/Explorer, so `git add` failed with
    // `No such file or directory`. Internal dots and spaces are kept. The
    // `.lua` extension is appended AFTER the trailing-strip so we don't end
    // up with `Foo..lua`.
    expect(sanitizeModuleFilename("Module:Exchange/Premade blurb' sp.")).toBe(
      "Exchange__Premade blurb' sp.lua",
    );
    expect(sanitizeModuleFilename("Module:trailing space ")).toBe("trailing space.lua");
    expect(sanitizeModuleFilename("Module:many dots...")).toBe("many dots.lua");
    expect(sanitizeModuleFilename("Module:mixed . . .")).toBe("mixed.lua");
  });
});
