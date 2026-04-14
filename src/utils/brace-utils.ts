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
    if (i + 1 < len && text[i] === '{' && text[i + 1] === '{') {
      depth++;
      i += 2;
    } else if (i + 1 < len && text[i] === '}' && text[i + 1] === '}') {
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
 * Extracts all template bodies for a given template name.
 *
 * Finds all occurrences of '{{templateName|...}}' blocks and returns
 * the raw template body strings (content between the outer braces).
 *
 * @param text - The text to search
 * @param templateName - The name of the template to find
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
  const searchPrefix = `{{${templateName}|`;
  let searchStart = 0;

  while (searchStart < text.length) {
    const prefixIndex = text.indexOf(searchPrefix, searchStart);

    if (prefixIndex === -1) {
      break;
    }

    const bodyStart = prefixIndex + searchPrefix.length;
    const endIndex = findTemplateEnd(text, prefixIndex);

    if (endIndex === -1) {
      break;
    }

    const bodyEnd = endIndex - 2;
    const body = text.slice(bodyStart, bodyEnd);
    results.push(body);

    searchStart = endIndex;
  }

  return results;
}
