/**
 * Utility functions for finding template boundaries using brace depth tracking.
 * @module brace-utils
 */

/**
 * Finds the end index of a template by tracking brace depth.
 *
 * Scans from startOffset, incrementing depth on '{{' and decrementing on '}}'.
 * Returns the index AFTER the closing '}}' when depth returns to 0.
 * Handles nested templates correctly: '{{outer {{inner}} text}}' closes inner first.
 *
 * @param text - The text to scan
 * @param startOffset - Starting position (default 0)
 * @returns Index after closing '}}', or -1 if no matching close found
 *
 * @example
 * ```typescript
 * const text = '{{outer {{inner}} text}}';
 * const end = findTemplateEnd(text, 0); // returns text.length
 * ```
 */
export function findTemplateEnd(text: string, startOffset = 0): number {
  let depth = 0;
  let i = startOffset;
  const len = text.length;

  while (i < len) {
    if (i + 1 < len && text[i] === "{" && text[i + 1] === "{") {
      depth++;
      i += 2;
    } else if (i + 1 < len && text[i] === "}" && text[i + 1] === "}") {
      depth--;
      if (depth === 0) {
        return i + 2;
      }
      i += 2;
    } else {
      i++;
    }
  }

  return -1;
}

/**
 * Escapes a string for safe inclusion in a RegExp. Used by template finders
 * that build patterns from user-supplied template names.
 */
function escapeRegex(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Extracts all template bodies for a given template name.
 *
 * Finds all occurrences of `{{templateName|...}}` blocks and returns
 * the raw template body strings (content between the outer braces).
 *
 * Tolerates optional whitespace (including newlines) between the template
 * name and the leading pipe, so multi-line templates such as
 * `{{Quest details\n|start = ...\n}}` are matched alongside the single-line
 * `{{Update|date=...}}` form.
 *
 * @param text - The text to search
 * @param templateName - The name of the template to find (case-sensitive)
 * @returns Array of template body strings (without {{ and }})
 *
 * @example
 * ```typescript
 * const text = '{{Infobox|item}}{{Infobox|weapon}}';
 * const bodies = extractTemplate(text, 'Infobox');
 * // bodies === ['item', 'weapon']
 * ```
 */
export function extractTemplate(text: string, templateName: string): string[] {
  const results: string[] = [];
  const pattern = new RegExp(`\\{\\{\\s*${escapeRegex(templateName)}\\s*\\|`, "g");
  let match: RegExpExecArray | null;

  while ((match = pattern.exec(text)) !== null) {
    const prefixIndex = match.index;
    const bodyStart = prefixIndex + match[0].length;
    const endIndex = findTemplateEnd(text, prefixIndex);

    if (endIndex === -1) {
      break;
    }

    const bodyEnd = endIndex - 2;
    const body = text.slice(bodyStart, bodyEnd);
    results.push(body);

    pattern.lastIndex = endIndex;
  }

  return results;
}

/**
 * Splits a template body into top-level `|`-delimited parameters, respecting
 * nested `{{...}}` and `[[...]]` regions so pipes inside links or nested
 * templates don't break the split.
 *
 * @param body - Template body without the surrounding `{{ }}`
 * @returns Array of raw param chunks (e.g. `key = value` strings)
 *
 * @example
 * ```typescript
 * splitTemplateParams('start = A | items = [[Egg]] | note = {{SCP|X|1}}');
 * // ['start = A ', ' items = [[Egg]] ', ' note = {{SCP|X|1}}']
 * ```
 */
export function splitTemplateParams(body: string): string[] {
  const parts: string[] = [];
  let depth = 0;
  let start = 0;
  for (let i = 0; i < body.length; i++) {
    const c = body[i];
    const c2 = body[i + 1];
    if ((c === "{" && c2 === "{") || (c === "[" && c2 === "[")) {
      depth++;
      i++;
    } else if ((c === "}" && c2 === "}") || (c === "]" && c2 === "]")) {
      depth = Math.max(0, depth - 1);
      i++;
    } else if (c === "|" && depth === 0) {
      parts.push(body.slice(start, i));
      start = i + 1;
    }
  }
  parts.push(body.slice(start));
  return parts;
}

/**
 * Parses a raw template body into a lower-cased key → value map.
 *
 * Uses {@link splitTemplateParams} so nested templates and links inside values
 * are preserved. Values are trimmed but otherwise returned verbatim (callers
 * can apply {@link wikiString} / bullet-list parsing as needed). Positional
 * params (no `=`) are skipped.
 *
 * @param body - Template body without the surrounding `{{ }}`
 * @returns Map of lower-cased key → raw value
 */
export function parseTemplateFields(body: string): Record<string, string> {
  const params: Record<string, string> = {};
  for (const part of splitTemplateParams(body)) {
    const eq = part.indexOf("=");
    if (eq === -1) continue;
    const key = part.slice(0, eq).trim().toLowerCase();
    const value = part.slice(eq + 1).trim();
    if (key) params[key] = value;
  }
  return params;
}
