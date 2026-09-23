import { mkdtempSync, readFileSync, rmSync } from "fs";
import { tmpdir } from "os";
import path from "path";
import { safeWriteFileSync } from "./safe-write";

describe("safeWriteFileSync", () => {
  let dir: string;

  beforeEach(() => {
    dir = mkdtempSync(path.join(tmpdir(), "safe-write-"));
  });

  afterEach(() => {
    rmSync(dir, { recursive: true, force: true });
  });

  it("writes the file content", async () => {
    const target = path.join(dir, "out.json");
    await safeWriteFileSync(target, '{"ok":true}');
    expect(readFileSync(target, "utf8")).toBe('{"ok":true}');
  });

  it("rethrows non-transient errors immediately", async () => {
    // Writing onto a directory yields EISDIR, which is not a transient
    // lock error — it must surface on the first attempt.
    await expect(safeWriteFileSync(dir, "nope")).rejects.toThrow();
  });
});
