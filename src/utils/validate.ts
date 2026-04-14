/**
 * Validation utilities for checking parsed wiki data before constructing typed objects.
 * Logs warnings for missing or malformed fields instead of silently producing garbage data.
 */

/**
 * Validates that required fields exist in parsed data. Returns list of missing field names.
 */
export function getMissingFields(
  data: Record<string, unknown>,
  requiredFields: string[]
): string[] {
  return requiredFields.filter((field) => {
    const value = data[field];
    return value === undefined || value === null || value === '';
  });
}

/**
 * Validates a numeric ID field. Returns the validated number or null with a warning.
 */
export function validateId(
  rawId: unknown,
  context: string,
  logger?: { warn: (...args: unknown[]) => void }
): number | null {
  const id = typeof rawId === 'number' ? rawId : Number(rawId);
  if (!Number.isFinite(id) || id <= 0) {
    logger?.warn(`Invalid ID in ${context}: ${String(rawId)}`);
    return null;
  }
  return id;
}

/**
 * Logs warnings for a parsed result that has validation issues.
 * Returns the number of warnings logged.
 */
export function logValidationWarnings(
  context: string,
  data: Record<string, unknown>,
  requiredFields: string[],
  logger?: { warn: (...args: unknown[]) => void }
): number {
  if (!logger) return 0;

  const missing = getMissingFields(data, requiredFields);
  if (missing.length > 0) {
    logger.warn(`${context}: missing required fields: ${missing.join(', ')}`);
  }
  return missing.length;
}
