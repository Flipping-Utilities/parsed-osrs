import { writeFileSync } from "fs";

/**
 * Error codes that indicate a transient inability to open a file for
 * writing — typically a Windows sharing violation: antivirus real-time
 * scans, editor/indexer language servers, or a `nest start --watch`
 * restart racing the previous process. Retrying after a short backoff
 * succeeds in practice; permanent errors (ENOSPC, ENOENT dir missing)
 * are rethrown immediately.
 */
const TRANSIENT_WRITE_ERRORS = new Set(["EBUSY", "EPERM", "EAGAIN", "UNKNOWN"]);

const RETRY_ATTEMPTS = 5;
const RETRY_BASE_DELAY_MS = 250;

function isTransientWriteError(e: unknown): boolean {
  return (
    typeof e === "object" &&
    e !== null &&
    "code" in e &&
    TRANSIENT_WRITE_ERRORS.has(String((e as { code?: unknown }).code))
  );
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * `writeFileSync` with retry-on-transient-lock semantics.
 *
 * On Windows, another process holding the target (AV scanner, JSON
 * language server, a --watch restart) makes `open` fail with EBUSY or
 * UNKNOWN (-4094) for the instant the file is locked. This helper
 * retries with linear backoff and rethrows the last error if the lock
 * persists (or the error is not transient).
 */
export async function safeWriteFileSync(
  path: string,
  data: string,
  attempts = RETRY_ATTEMPTS,
): Promise<void> {
  for (let attempt = 1; ; attempt++) {
    try {
      writeFileSync(path, data);
      return;
    } catch (e) {
      if (attempt >= attempts || !isTransientWriteError(e)) {
        throw e;
      }
      await sleep(RETRY_BASE_DELAY_MS * attempt);
    }
  }
}
