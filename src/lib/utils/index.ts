/**
 * Stub implementations of Remeda utility functions
 * These are simplified versions of the actual Remeda methods
 */

/**
 * Checks if an array or object is empty
 */
export function isEmpty<T extends unknown[] | Record<string, unknown>>(value: T): boolean {
  if (Array.isArray(value)) {
    return value.length === 0;
  }

  if (typeof value === "object" && value !== null) {
    return Object.keys(value).length === 0;
  }

  return false;
}

/**
 * Groups array items by a key extracted with the callback function
 */
export function groupBy<T, K extends string | number | symbol>(
  array: T[],
  callback: (item: T) => K
): Record<K, T[]> {
  return array.reduce(
    (result, item) => {
      const key = callback(item);
      if (!result[key]) {
        result[key] = [];
      }
      result[key].push(item);
      return result;
    },
    {} as Record<K, T[]>
  );
}

/**
 * Maps an array using a callback function
 */
export function map<T, U>(array: T[], callback: (item: T) => U): U[] {
  return array.map(callback);
}

/**
 * Get characters from the alphabet based on an index and use multiple characters (similar to excel) if the index exceeds the length of the alphabet.
 */
const alphabet = "abcdefghijklmnopqrstuvwxyzæøå".split("");
export function getCharacters(index: number): string {
  const base = alphabet.length;
  let n = index;
  let result: string = "";

  while (n >= 0) {
    result = alphabet[n % base]!.toUpperCase() + result;
    n = Math.floor(n / base) - 1;
  }

  return result;
}
