import { describe, expect, it, vi } from "vitest";
import { mergeRedirects, PageListDumper } from "./page-list.dumper";
import type { WikiPage } from "../database/schema";
import type { WikiRequestService } from "../wiki/wikiRequest.service";
import type { DatabaseService } from "../database/database.service";

type WikiPageRow = typeof WikiPage.$inferSelect;

// Factory for a DB row. Only the fields mergeRedirects cares about are set;
// the rest are omitted via Partial and defaulted in the helper below.
function makePage(opts: {
  id: number;
  aliases?: string[] | null;
}): Pick<WikiPageRow, "id" | "aliases"> {
  return {
    id: opts.id,
    aliases: (opts.aliases ?? null) as WikiPageRow["aliases"],
  };
}

function makeResponse(opts: {
  pageid: number;
  redirects?: Array<{ title: string; ns: number; pageid: number }>;
}) {
  return {
    pageid: opts.pageid,
    title: `Page:${opts.pageid}`,
    redirects: opts.redirects,
  };
}

describe("mergeRedirects", () => {
  describe("correctness", () => {
    it("attaches each redirect list to the right page", () => {
      const pages = [makePage({ id: 1, aliases: [] }), makePage({ id: 2, aliases: [] })];
      const responses = [
        makeResponse({
          pageid: 1,
          redirects: [{ title: "Alias A", ns: 0, pageid: 100 }],
        }),
        makeResponse({
          pageid: 2,
          redirects: [{ title: "Alias B", ns: 0, pageid: 200 }],
        }),
      ];

      const result = mergeRedirects(pages, responses);

      expect(result).toEqual([
        { id: 1, aliases: ["Alias A"] },
        { id: 2, aliases: ["Alias B"] },
      ]);
    });

    it("merges new redirects into existing aliases without duplicates", () => {
      const pages = [makePage({ id: 1, aliases: ["Existing"] })];
      const responses = [
        makeResponse({
          pageid: 1,
          redirects: [
            { title: "Existing", ns: 0, pageid: 100 },
            { title: "New", ns: 0, pageid: 101 },
          ],
        }),
      ];

      const result = mergeRedirects(pages, responses);

      expect(result).toEqual([{ id: 1, aliases: ["Existing", "New"] }]);
    });

    it("accumulates redirects across multiple responses for the same pageid (pagination)", () => {
      // A page with >500 redirects spans multiple `rdcontinue` pages in the
      // API response; each page returns the same pageid with a partial list.
      const pages = [makePage({ id: 1, aliases: [] })];
      const responses = [
        makeResponse({
          pageid: 1,
          redirects: [{ title: "Alias A", ns: 0, pageid: 100 }],
        }),
        makeResponse({
          pageid: 1,
          redirects: [{ title: "Alias B", ns: 0, pageid: 101 }],
        }),
      ];

      const result = mergeRedirects(pages, responses);

      expect(result).toEqual([{ id: 1, aliases: ["Alias A", "Alias B"] }]);
    });

    it("preserves existing aliases even when absent from the response (no pruning)", () => {
      // Old behaviour only ever added aliases; mergeRedirects must match that.
      const pages = [makePage({ id: 1, aliases: ["Old Alias"] })];
      const responses = [
        makeResponse({
          pageid: 1,
          redirects: [{ title: "New Alias", ns: 0, pageid: 101 }],
        }),
      ];

      const result = mergeRedirects(pages, responses);

      expect(result).toEqual([{ id: 1, aliases: ["Old Alias", "New Alias"] }]);
    });
  });

  describe("delta skip — only return rows whose aliases actually changed", () => {
    it("omits a page when every incoming redirect is already in aliases", () => {
      const pages = [makePage({ id: 1, aliases: ["Alias A", "Alias B"] })];
      const responses = [
        makeResponse({
          pageid: 1,
          redirects: [
            { title: "Alias A", ns: 0, pageid: 100 },
            { title: "Alias B", ns: 0, pageid: 101 },
          ],
        }),
      ];

      const result = mergeRedirects(pages, responses);

      expect(result).toEqual([]);
    });

    it("includes a page when at least one incoming redirect is new", () => {
      const pages = [makePage({ id: 1, aliases: ["Alias A"] })];
      const responses = [
        makeResponse({
          pageid: 1,
          redirects: [
            { title: "Alias A", ns: 0, pageid: 100 },
            { title: "Alias B", ns: 0, pageid: 101 },
          ],
        }),
      ];

      const result = mergeRedirects(pages, responses);

      expect(result).toHaveLength(1);
      expect(result[0].aliases).toEqual(["Alias A", "Alias B"]);
    });

    it("omits a page whose existing aliases are a strict superset of the response", () => {
      const pages = [makePage({ id: 1, aliases: ["A", "B", "C"] })];
      const responses = [
        makeResponse({
          pageid: 1,
          redirects: [{ title: "A", ns: 0, pageid: 100 }],
        }),
      ];

      const result = mergeRedirects(pages, responses);

      expect(result).toEqual([]);
    });
  });

  describe("edge cases", () => {
    it("treats null aliases as an empty list", () => {
      const pages = [makePage({ id: 1, aliases: null })];
      const responses = [
        makeResponse({
          pageid: 1,
          redirects: [{ title: "Alias A", ns: 0, pageid: 100 }],
        }),
      ];

      const result = mergeRedirects(pages, responses);

      expect(result).toEqual([{ id: 1, aliases: ["Alias A"] }]);
    });

    it("skips redirect responses for unknown pageids", () => {
      const pages = [makePage({ id: 1, aliases: [] })];
      const responses = [
        makeResponse({
          pageid: 999,
          redirects: [{ title: "Ghost", ns: 0, pageid: 100 }],
        }),
        makeResponse({
          pageid: 1,
          redirects: [{ title: "Real", ns: 0, pageid: 101 }],
        }),
      ];

      const result = mergeRedirects(pages, responses);

      expect(result).toEqual([{ id: 1, aliases: ["Real"] }]);
    });

    it("handles a response with no redirects property", () => {
      const pages = [makePage({ id: 1, aliases: [] })];
      const responses = [{ pageid: 1, title: "Page:1" }];

      const result = mergeRedirects(pages, responses);

      expect(result).toEqual([]);
    });

    it("handles empty inputs", () => {
      expect(mergeRedirects([], [])).toEqual([]);
      expect(mergeRedirects([makePage({ id: 1, aliases: [] })], [])).toEqual([]);
    });

    it("does not mutate the input pages array", () => {
      const pages = [makePage({ id: 1, aliases: ["Original"] })];
      const responses = [
        makeResponse({
          pageid: 1,
          redirects: [{ title: "Added", ns: 0, pageid: 100 }],
        }),
      ];

      mergeRedirects(pages, responses);

      expect(pages[0].aliases).toEqual(["Original"]);
    });
  });
});

// ---------------------------------------------------------------------------
// Orchestration tests: verify the dumpRedirectList method itself drives the
// wiki client and DB correctly (chunking, await, delta plumbing).
// ---------------------------------------------------------------------------

// Build a mock drizzle db that records every batch invocation. Each recorded
// entry carries the parsed `{ id, aliases }` payload so tests can assert on
// semantics without depending on drizzle's internal statement shape.
function makeMockDb(pagesInDb: WikiPageRow[]) {
  const batchedUpdates: Array<Array<{ id: number; aliases: string[] }>> = [];
  const batchSpy = vi.fn(async (stmts: Array<{ _payload: unknown }>) => {
    const parsed = stmts.map((s) => s._payload as { id: number; aliases: string[] });
    batchedUpdates.push(parsed);
  });
  const db = {
    select: vi.fn(() => ({ from: () => Promise.resolve(pagesInDb) })),
    update: vi.fn(() => ({
      set: (data: { aliases: string[] }) => ({
        where: (cond: unknown) => ({ _payload: data, _cond: cond }),
      }),
    })),
    batch: batchSpy,
  };
  return { db, batchedUpdates, batchSpy };
}

function makeRow(opts: { id: number; aliases?: string[] | null }): WikiPageRow {
  return {
    id: opts.id,
    title: `Page:${opts.id}`,
    aliases: (opts.aliases ?? null) as WikiPageRow["aliases"],
    html: null,
    model: null,
    namespace: 0,
    parentId: null,
    revisionId: null,
    fullfetchRevisionId: null,
    text: null,
    timestamp: null,
  } as WikiPageRow;
}

describe("PageListDumper.dumpRedirectList orchestration", () => {
  function makeDumper(pagesInDb: WikiPageRow[]) {
    const { db, batchedUpdates, batchSpy } = makeMockDb(pagesInDb);
    const wiki = {
      queryAllPagesPromise: vi.fn(),
    };
    const databaseService = { getDb: () => db };
    const dumper = new PageListDumper(
      wiki as unknown as WikiRequestService,
      databaseService as unknown as DatabaseService,
    );
    return { dumper, wiki, batchedUpdates, batchSpy };
  }

  it("chunks DB updates into batches of at most 1000", async () => {
    // 2500 pages, each with a brand-new alias → all need updating.
    const pages = Array.from({ length: 2500 }, (_, i) => makeRow({ id: i + 1, aliases: [] }));
    const { dumper, wiki, batchedUpdates } = makeDumper(pages);

    wiki.queryAllPagesPromise.mockImplementation(
      async (_cont: string, _key: string, params: { titles: string }) => {
        const requested = params.titles.split("|");
        return requested.map((title) => {
          const id = Number(title.split(":")[1]);
          return {
            pageid: id,
            title,
            redirects: [{ title: `Alias:${id}`, ns: 0, pageid: 100000 + id }],
          };
        });
      },
    );

    await dumper.dumpRedirectList();

    // 2500 / 1000 = 3 chunks
    expect(batchedUpdates).toHaveLength(3);
    expect(batchedUpdates[0]).toHaveLength(1000);
    expect(batchedUpdates[1]).toHaveLength(1000);
    expect(batchedUpdates[2]).toHaveLength(500);
  });

  it("awaits each DB batch before returning (regression test for the old dropped promise)", async () => {
    const pages = [makeRow({ id: 1, aliases: [] })];
    const { dumper, wiki, batchSpy } = makeDumper(pages);

    let batchResolved = false;
    batchSpy.mockImplementation(async () => {
      await new Promise((r) => setTimeout(r, 10));
      batchResolved = true;
    });

    wiki.queryAllPagesPromise.mockResolvedValue([
      {
        pageid: 1,
        title: "Page:1",
        redirects: [{ title: "NewAlias", ns: 0, pageid: 100 }],
      },
    ]);

    await dumper.dumpRedirectList();

    // If the await were missing, batchResolved would still be false here.
    expect(batchResolved).toBe(true);
    expect(batchSpy).toHaveBeenCalled();
  });

  it("does not issue any DB batch when no aliases changed (delta skip)", async () => {
    const pages = [makeRow({ id: 1, aliases: ["AlreadyKnown"] })];
    const { dumper, wiki, batchSpy } = makeDumper(pages);

    wiki.queryAllPagesPromise.mockResolvedValue([
      {
        pageid: 1,
        title: "Page:1",
        redirects: [{ title: "AlreadyKnown", ns: 0, pageid: 100 }],
      },
    ]);

    await dumper.dumpRedirectList();

    expect(batchSpy).not.toHaveBeenCalled();
  });

  it("queries the wiki in title chunks of 50", async () => {
    const pages = Array.from({ length: 120 }, (_, i) => makeRow({ id: i + 1, aliases: [] }));
    const { dumper, wiki } = makeDumper(pages);

    wiki.queryAllPagesPromise.mockResolvedValue([]);

    await dumper.dumpRedirectList();

    // 120 / 50 = 3 title chunks (rounded up)
    expect(wiki.queryAllPagesPromise).toHaveBeenCalledTimes(3);
    for (const call of wiki.queryAllPagesPromise.mock.calls) {
      const params = call[2] as { titles: string };
      expect(params.titles.split("|").length).toBeLessThanOrEqual(50);
    }
  });

  it("passes the correct payload through to each DB update", async () => {
    const pages = [makeRow({ id: 42, aliases: ["Old"] })];
    const { dumper, wiki, batchedUpdates } = makeDumper(pages);

    wiki.queryAllPagesPromise.mockResolvedValue([
      {
        pageid: 42,
        title: "Page:42",
        redirects: [
          { title: "Old", ns: 0, pageid: 100 },
          { title: "New", ns: 0, pageid: 101 },
        ],
      },
    ]);

    await dumper.dumpRedirectList();

    // The `set()` payload is `{ aliases }`; the `id` lives in the WHERE
    // clause (`eq(WikiPage.id, id)`), whose drizzle-internal shape isn't
    // stable enough to assert on here. The id→aliases mapping is already
    // proven by the mergeRedirects unit tests; here we just verify the
    // correct aliases payload reaches the DB.
    expect(batchedUpdates).toEqual([[{ aliases: ["Old", "New"] }]]);
  });

  it("handles an empty page list without issuing any requests", async () => {
    const { dumper, wiki, batchSpy } = makeDumper([]);

    await dumper.dumpRedirectList();

    expect(wiki.queryAllPagesPromise).not.toHaveBeenCalled();
    expect(batchSpy).not.toHaveBeenCalled();
  });
});
