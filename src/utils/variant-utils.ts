/**
 * Utility functions for detecting and handling multi-variant items in wiki data.
 * @module variant-utils
 */

/**
 * Result object from extractVariants function.
 */
export interface VariantResult {
  /** Whether any variants were detected */
  hasVariants: boolean;
  /** Array of variant objects, each containing fields for a specific variant index */
  variants: Array<{ index: number; fields: Record<string, unknown> }>;
  /** Fields without numeric suffixes, shared across all variants */
  commonFields: Record<string, unknown>;
}

/**
 * Extracts variants from a key-value record by detecting trailing digits in keys.
 *
 * Keys with trailing numeric suffixes (e.g., id2, name2) are grouped by their suffix index
 * into variant objects. Keys without trailing digits are treated as common fields.
 *
 * @example
 * ```typescript
 * const input = {
 *   id: 1,
 *   id2: 2,
 *   name: 'Potion',
 *   name2: 'Potion (2)',
 *   weight: 0.5
 * };
 * const result = extractVariants(input);
 * // result.hasVariants === true
 * // result.commonFields === { id: 1, name: 'Potion', weight: 0.5 }
 * // result.variants === [{ index: 2, fields: { id2: 2, name2: 'Potion (2)' } }]
 * ```
 *
 * @param kv - The record to analyze for variants
 * @returns VariantResult with detected variants and common fields
 */
export function extractVariants(kv: Record<string, unknown>): VariantResult {
  const commonFields: Record<string, unknown> = {};
  const variantMap: Map<number, Record<string, unknown>> = new Map();

  const keyRegex = /^(.+?)(\d+)$/;

  for (const [key, value] of Object.entries(kv)) {
    const match = key.match(keyRegex);

    if (match) {
      const baseName = match[1];
      const index = parseInt(match[2], 10);

      if (!variantMap.has(index)) {
        variantMap.set(index, {});
      }

      const variant = variantMap.get(index)!;
      variant[key] = value;
    } else {
      commonFields[key] = value;
    }
  }

  const variants: VariantResult["variants"] = [];

  for (const [index, fields] of variantMap) {
    variants.push({
      index,
      fields,
    });
  }

  // Sort by index
  variants.sort((a, b) => a.index - b.index);

  const hasVariants = variants.length > 0;

  return {
    hasVariants,
    variants,
    commonFields,
  };
}

/**
 * Gets a field value from either a variant or common fields.
 *
 * @param variant - The variant-specific fields record
 * @param commonFields - The common fields shared across variants
 * @param baseKey - The base key name to look up (without numeric suffix)
 * @returns The value from variant, commonFields, or undefined
 *
 * @example
 * ```typescript
 * const variant = { id2: 2, name2: 'Potion (2)' };
 * const commonFields = { id: 1, name: 'Potion', weight: 0.5 };
 *
 * getVariantField(variant, commonFields, 'id');     // returns 2
 * getVariantField(variant, commonFields, 'name');   // returns 'Potion (2)'
 * getVariantField(variant, commonFields, 'weight'); // returns 0.5
 * getVariantField(variant, commonFields, 'none');   // returns undefined
 * ```
 */
export function getVariantField(
  variant: Record<string, unknown>,
  commonFields: Record<string, unknown>,
  baseKey: string,
): unknown {
  // Get the index from variant fields (look for any key ending with a digit)
  const variantKeys = Object.keys(variant);
  let index: number | null = null;

  for (const vKey of variantKeys) {
    const match = vKey.match(/^(.+?)(\d+)$/);
    if (match && match[1] === baseKey) {
      index = parseInt(match[2], 10);
      break;
    }
  }

  if (index !== null) {
    const variantKey = `${baseKey}${index}`;
    if (variantKey in variant) {
      return variant[variantKey];
    }
  }

  if (baseKey in commonFields) {
    return commonFields[baseKey];
  }

  return undefined;
}
