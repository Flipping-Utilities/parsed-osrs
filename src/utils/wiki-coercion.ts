/**
 * Wiki value coercion utilities for all extractors.
 * @packageDocumentation
 */

/**
 * Converts a wiki boolean value to a JavaScript boolean.
 *
 * Returns `true` ONLY for:
 * - `true` (boolean)
 * - `'Yes'` or `'yes'` (case-insensitive string)
 *
 * Returns `false` for everything else:
 * - `false`, `'No'`, `'no'`, `null`, `undefined`, `0`, empty string, etc.
 *
 * @param val - The value to coerce
 * @returns The coerced boolean value
 *
 * @example
 * ```typescript
 * wikiBool(true);        // true
 * wikiBool('Yes');       // true
 * wikiBool('yes');       // true
 * wikiBool('YES');       // false (not exactly 'Yes')
 * wikiBool(false);       // false
 * wikiBool('No');        // false
 * wikiBool(null);        // false
 * wikiBool(undefined);   // false
 * wikiBool(0);          // false
 * wikiBool('');         // false
 * ```
 */
export function wikiBool(val: unknown, fallback = false): boolean {
  if (val === null || val === undefined || val === '') {
    return fallback;
  }
  if (val === true) {
    return true;
  }

  if (typeof val === 'string') {
    const lower = val.toLowerCase();
    if (lower === 'yes') {
      return true;
    }
  }

  return false;
}

/**
 * Converts a wiki value to a number with fallback for invalid values.
 *
 * Handles:
 * - Numeric strings: `'+82'` → `82`, `'-15'` → `-15`, `'1.8'` → `1.8`
 * - Comma-separated values: `'2,3,4'` → `2` (returns first value)
 * - `null`/`undefined` → `fallback`
 * - Invalid values (`NaN`, `Infinity`) → `fallback`
 *
 * @param val - The value to coerce
 * @param fallback - The fallback value for invalid inputs (default: 0)
 * @returns The coerced number or fallback
 *
 * @example
 * ```typescript
 * wikiNumber('+82');          // 82
 * wikiNumber('-15');          // -15
 * wikiNumber('1.8');          // 1.8
 * wikiNumber('2,3,4');        // 2
 * wikiNumber(42);             // 42
 * wikiNumber(null);           // 0
 * wikiNumber(undefined);      // 0
 * wikiNumber('invalid');      // 0
 * wikiNumber('2,3,4', 100);   // 2
 * ```
 */
export function wikiNumber(val: unknown, fallback = 0): number {
  if (val === null || val === undefined) {
    return fallback;
  }

  let strVal: string;
  if (typeof val === 'number') {
    strVal = String(val);
  } else if (typeof val === 'string') {
    strVal = val;
  } else {
    strVal = String(val);
  }

  if (strVal.includes(',')) {
    const parts = strVal.split(',');
    const firstPart = parts[0].trim();
    const firstResult = Number(firstPart);
    if (!Number.isNaN(firstResult) && Number.isFinite(firstResult)) {
      return firstResult;
    }
  }

  // Strip commas from numeric strings (e.g., "1,000" → "1000")
  const normalized = strVal.replace(/,/g, '');
  const result = Number(normalized);

  if (Number.isNaN(result) || !Number.isFinite(result)) {
    return fallback;
  }

  return result;
}

/**
 * Converts a wiki value to a clean string, stripping MediaWiki markup.
 *
 * Stripping rules:
 * - `[[link]]` → `link`
 * - `[[File:image.png|thumb|caption]]` → `` (removes file references entirely)
 * - `[[target|display text]]` → `display text` (uses display text)
 * - `''italic''` → `italic`
 * - `'''bold'''` → `bold`
 *
 * Returns empty string for `null`/`undefined`.
 * Trims whitespace.
 *
 * @param val - The value to coerce
 * @returns The cleaned string
 *
 * @example
 * ```typescript
 * wikiString('plain text');           // 'plain text'
 * wikiString('[[link]]');             // 'link'
 * wikiString('[[Target|Display]]');   // 'Display'
 * wikiString('[[File:image.png]]');   // ''
 * wikiString("''italic''");           // 'italic'
 * wikiString("'''bold'''");           // 'bold'
 * wikiString(null);                   // ''
 * wikiString(undefined);             // ''
 * ```
 */
export function wikiString(val: unknown): string {
  if (val === null || val === undefined) {
    return '';
  }

  let str = String(val);

  // Remove [[File:...]] references entirely
  str = str.replace(/\[\[File:[^\]]+\]\]/gi, '');

  // Handle [[target|display text]] → display text
  // Handle [[link]] → link
  str = str.replace(/\[\[([^|\]]+)\|([^\]]+)\]\]/g, '$2');
  str = str.replace(/\[\[([^\]]+)\]\]/g, '$1');

  // Handle ''italic'' → italic
  str = str.replace(/''([^']+)''/g, '$1');

  // Handle '''bold''' → bold
  str = str.replace(/'''([^']+)'''/g, '$1');

  return str.trim();
}

export function parseListValue(value: unknown): string[] {
  if (!value) return [];
  return String(value)
    .split(',')
    .map((v) => v.trim())
    .filter(Boolean);
}
