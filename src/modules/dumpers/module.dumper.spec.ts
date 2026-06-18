import {
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  rmSync,
  writeFileSync,
} from 'fs';
import path from 'path';
import { beforeEach, afterEach, describe, expect, it, vi } from 'vitest';

// vi.mock factories are hoisted above all top-level statements, so any value
// they close over must itself be hoisted. We can't use the `path` import
// inside the hoisted callback (it hasn't been initialized yet), so plain
// string concatenation it is.
const { TEST_DIR, TEST_MODULES_FOLDER } = vi.hoisted(() => {
  // __dirname here points at src/modules/dumpers/. Go up three segments to
  // the package root, then into test/.tmp-module-dumper/modules.
  const root = __dirname.split(/[\\/]/).slice(0, -3).join('/');
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
vi.mock('../../constants/paths', () => ({
  MODULES_FOLDER: TEST_MODULES_FOLDER,
}));

import { ModuleDumper, sanitizeModuleFilename } from './module.dumper';
import type {
  WikiRequestService,
  WikiPageWithContent,
} from '../wiki/wikiRequest.service';

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
    rawContent: opts.content ?? '',
    content: '',
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

describe('ModuleDumper', () => {
  let wiki: ReturnType<typeof makeMockWikiService>;

  beforeEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
    mkdirSync(TEST_MODULES_FOLDER, { recursive: true });
    wiki = makeMockWikiService();
  });

  afterEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
  });

  describe('dumpAllModules — equivalence with old per-module approach', () => {
    it('writes the same on-disk files the old getRawText loop would have written', async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: 'Module:Foo', ns: 828 },
        { pageid: 2, title: 'Module:Bar/sub', ns: 828 },
        { pageid: 3, title: 'Module:GELimits/data.json', ns: 828 },
        { pageid: 4, title: 'Module:Has Space', ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({ pageid: 1, title: 'Module:Foo', content: 'foo-source' }),
        makePage({
          pageid: 2,
          title: 'Module:Bar/sub',
          content: 'bar-sub-source',
        }),
        makePage({
          pageid: 3,
          title: 'Module:GELimits/data.json',
          content: 'return { ... }',
        }),
        makePage({
          pageid: 4,
          title: 'Module:Has Space',
          content: 'with-space',
        }),
      ]);

      await dumper.dumpAllModules();

      // The OLD toFilePath() strips "Module:", replaces "/" with "__".
      expect(readFileSync(path.join(TEST_MODULES_FOLDER, 'Foo'), 'utf8')).toBe(
        'foo-source'
      );
      expect(
        readFileSync(path.join(TEST_MODULES_FOLDER, 'Bar__sub'), 'utf8')
      ).toBe('bar-sub-source');
      expect(
        readFileSync(
          path.join(TEST_MODULES_FOLDER, 'GELimits__data.json'),
          'utf8'
        )
      ).toBe('return { ... }');
      expect(
        readFileSync(path.join(TEST_MODULES_FOLDER, 'Has Space'), 'utf8')
      ).toBe('with-space');
    });
  });

  describe('dumpAllModules — batching (50x fewer requests)', () => {
    it('never calls getRawText; only batched queryPagesByIds', async () => {
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
          })
        )
      );

      await dumper.dumpAllModules();

      expect(wiki.getRawText).not.toHaveBeenCalled();
      // 110 modules / 50-per-batch = 3 calls
      expect(wiki.queryPagesByIds).toHaveBeenCalledTimes(3);
    });

    it('chunks at the MediaWiki hard cap of 50 pageids per request', async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      const moduleList = Array.from({ length: 250 }, (_, i) => ({
        pageid: i,
        title: `Module:M${i}`,
        ns: 828,
      }));
      wiki.queryAllPagesPromise.mockResolvedValue(moduleList);
      wiki.queryPagesByIds.mockImplementation(async (ids: number[]) =>
        ids.map((id) =>
          makePage({ pageid: id, title: `Module:M${id}`, content: `s-${id}` })
        )
      );

      await dumper.dumpAllModules();

      // 250 / 50 = exactly 5 batches
      expect(wiki.queryPagesByIds).toHaveBeenCalledTimes(5);
      for (const call of wiki.queryPagesByIds.mock.calls) {
        expect(call[0].length).toBeLessThanOrEqual(50);
      }
    });

    it('handles an empty module list without issuing any requests', async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([]);

      await dumper.dumpAllModules();

      expect(wiki.queryPagesByIds).not.toHaveBeenCalled();
      expect(wiki.getRawText).not.toHaveBeenCalled();
    });
  });

  describe('dumpAllModules — delta skip (only write changed modules)', () => {
    it('does not rewrite files when the revid is unchanged since the previous run', async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: 'Module:Stable', ns: 828 },
        { pageid: 2, title: 'Module:Changed', ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:Stable',
          revid: 100,
          content: 'stable-v1',
        }),
        makePage({
          pageid: 2,
          title: 'Module:Changed',
          revid: 200,
          content: 'changed-v1',
        }),
      ]);

      await dumper.dumpAllModules();

      // Tamper with the on-disk "Stable" file. If the second run re-writes
      // unchanged modules, this tampering would be overwritten.
      writeFileSync(
        path.join(TEST_MODULES_FOLDER, 'Stable'),
        'TAMPERED-SHOULD-PERSIST'
      );

      // Second run: Stable unchanged, Changed bumped
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:Stable',
          revid: 100,
          content: 'stable-v1',
        }),
        makePage({
          pageid: 2,
          title: 'Module:Changed',
          revid: 201,
          content: 'changed-v2',
        }),
      ]);

      await dumper.dumpAllModules();

      expect(
        readFileSync(path.join(TEST_MODULES_FOLDER, 'Stable'), 'utf8')
      ).toBe('TAMPERED-SHOULD-PERSIST');
      expect(
        readFileSync(path.join(TEST_MODULES_FOLDER, 'Changed'), 'utf8')
      ).toBe('changed-v2');
    });

    it('still re-writes a module when its revid changes back to a previously-seen value', async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: 'Module:Revert', ns: 828 },
      ]);

      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:Revert',
          revid: 50,
          content: 'rev-50',
        }),
      ]);
      await dumper.dumpAllModules();

      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:Revert',
          revid: 51,
          content: 'rev-51',
        }),
      ]);
      await dumper.dumpAllModules();

      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:Revert',
          revid: 50,
          content: 'rev-50-restored',
        }),
      ]);
      await dumper.dumpAllModules();

      expect(
        readFileSync(path.join(TEST_MODULES_FOLDER, 'Revert'), 'utf8')
      ).toBe('rev-50-restored');
    });
  });

  describe('dumpAllModules — edge cases preserved from old behavior', () => {
    it('skips modules whose fetched source is empty (matches old null/empty skip)', async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: 'Module:HasContent', ns: 828 },
        { pageid: 2, title: 'Module:Empty', ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:HasContent',
          content: 'real source',
        }),
        makePage({ pageid: 2, title: 'Module:Empty', content: '' }),
      ]);

      await dumper.dumpAllModules();

      const files = readdirSync(TEST_MODULES_FOLDER).filter(
        (f) => !f.startsWith('.')
      );
      expect(files).toEqual(['HasContent']);
    });

    it('silently ignores pageids that no longer exist (missing in API response)', async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: 'Module:Alive', ns: 828 },
        { pageid: 2, title: 'Module:Deleted', ns: 828 },
      ]);
      // Real queryPagesByIds drops missing/invalid pages from its result.
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:Alive',
          content: 'alive-source',
        }),
      ]);

      await dumper.dumpAllModules();

      expect(
        readFileSync(path.join(TEST_MODULES_FOLDER, 'Alive'), 'utf8')
      ).toBe('alive-source');
      expect(existsSync(path.join(TEST_MODULES_FOLDER, 'Deleted'))).toBe(false);
    });

    it('preserves the subpage naming convention (slashes → __)', async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: 'Module:Deep/nested/page', ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:Deep/nested/page',
          content: 'deep',
        }),
      ]);

      await dumper.dumpAllModules();

      expect(
        readFileSync(
          path.join(TEST_MODULES_FOLDER, 'Deep__nested__page'),
          'utf8'
        )
      ).toBe('deep');
    });
  });

  describe('dumpAllModules — index persistence across processes', () => {
    it('persists a revision index that a fresh dumper instance reads on the next run', async () => {
      // First "process": dump the module, expect the index to be written.
      const firstDumper = new ModuleDumper(
        wiki as unknown as WikiRequestService
      );
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: 'Module:Persist', ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:Persist',
          revid: 42,
          content: 'persisted',
        }),
      ]);
      await firstDumper.dumpAllModules();

      // Plant a sentinel value on disk; a correctly-skipped second run will
      // NOT overwrite it.
      writeFileSync(path.join(TEST_MODULES_FOLDER, 'Persist'), 'PRE-RUN-VALUE');

      // Second "process": brand-new instance, same mocks, same revid → skip.
      const secondDumper = new ModuleDumper(
        wiki as unknown as WikiRequestService
      );
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({
          pageid: 1,
          title: 'Module:Persist',
          revid: 42,
          content: 'SHOULD-NOT-WRITE',
        }),
      ]);
      await secondDumper.dumpAllModules();

      expect(
        readFileSync(path.join(TEST_MODULES_FOLDER, 'Persist'), 'utf8')
      ).toBe('PRE-RUN-VALUE');
    });
  });

  describe('dumpAllModules — crash resistance', () => {
    it('continues dumping after a write failure instead of aborting the batch', async () => {
      const dumper = new ModuleDumper(wiki as unknown as WikiRequestService);
      wiki.queryAllPagesPromise.mockResolvedValue([
        { pageid: 1, title: 'Module:Good', ns: 828 },
        { pageid: 2, title: 'Module:Bad', ns: 828 },
        { pageid: 3, title: 'Module:AlsoGood', ns: 828 },
      ]);
      wiki.queryPagesByIds.mockResolvedValue([
        makePage({ pageid: 1, title: 'Module:Good', content: 'good-1' }),
        makePage({ pageid: 2, title: 'Module:Bad', content: 'bad' }),
        makePage({
          pageid: 3,
          title: 'Module:AlsoGood',
          content: 'good-3',
        }),
      ]);

      // Pre-create `Bad` as a directory so writeFileSync('...Bad', source)
      // fails with EISDIR — a natural write failure on every OS, no fs
      // mocking required. The production trigger was an ENOENT from a
      // Windows-reserved `:` in the filename, but any write error exercises
      // the same try/catch.
      mkdirSync(path.join(TEST_MODULES_FOLDER, 'Bad'));

      // Must NOT throw — the failure is caught and the dump continues.
      await dumper.dumpAllModules();

      expect(readFileSync(path.join(TEST_MODULES_FOLDER, 'Good'), 'utf8')).toBe(
        'good-1'
      );
      expect(
        readFileSync(path.join(TEST_MODULES_FOLDER, 'AlsoGood'), 'utf8')
      ).toBe('good-3');
    });
  });
});

describe('sanitizeModuleFilename', () => {
  it('strips the Module: namespace prefix', () => {
    expect(sanitizeModuleFilename('Module:Foo')).toBe('Foo');
  });

  it('replaces forward slashes with __ (subpage flattening)', () => {
    expect(sanitizeModuleFilename('Module:Foo/Bar/Baz')).toBe('Foo__Bar__Baz');
  });

  it('replaces colons with _ (Windows-reserved)', () => {
    expect(sanitizeModuleFilename('Module:User:Spoiledduc')).toBe(
      'User_Spoiledduc'
    );
  });

  it('handles the exact title from the production crash', () => {
    // This title produced an ENOENT on Windows because the sanitized name
    // still contained `:` characters from the User: namespace.
    const title = 'Module:Sandbox/User:Spoiledduc/Skill calc/AgilityBarb';
    const result = sanitizeModuleFilename(title);
    // No reserved characters should remain.
    expect(result).not.toMatch(/[:<>"|?*]/);
    expect(result).toBe('Sandbox__User_Spoiledduc__Skill calc__AgilityBarb');
  });

  it('handles a title with a double Module: prefix', () => {
    // Module:Module:Sandbox → strip first prefix → Module:Sandbox → : → _
    expect(sanitizeModuleFilename('Module:Module:Sandbox')).toBe(
      'Module_Sandbox'
    );
  });

  it('replaces all Windows-reserved characters', () => {
    const title = 'Module:A<B>C"D|E?F*G';
    const result = sanitizeModuleFilename(title);
    expect(result).toBe('A_B_C_D_E_F_G');
  });

  it('replaces backslashes with __', () => {
    expect(sanitizeModuleFilename('Module:Foo\\Bar')).toBe('Foo__Bar');
  });

  it('removes ../ traversal sequences', () => {
    // The `../` sequence is stripped first, then remaining `/` → `__`.
    expect(sanitizeModuleFilename('Module:../etc/passwd')).toBe('etc__passwd');
    expect(sanitizeModuleFilename('Module:../etc/../passwd')).toBe(
      'etc__passwd'
    );
  });

  it('preserves spaces and dots', () => {
    expect(sanitizeModuleFilename('Module:GELimits/data.json')).toBe(
      'GELimits__data.json'
    );
    expect(sanitizeModuleFilename('Module:Has Space')).toBe('Has Space');
  });
});
