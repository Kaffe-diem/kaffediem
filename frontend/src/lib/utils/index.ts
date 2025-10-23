/**
 * remeda-like utility helpers used across the app
 */

/** checks if an array or object is empty */
export function isEmpty<T extends unknown[] | Record<string, unknown>>(value: T): boolean {
  if (Array.isArray(value)) {
    return value.length === 0;
  }

  if (typeof value === "object" && value !== null) {
    return Object.keys(value).length === 0;
  }

  return false;
}

/** groups items by a key */
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

/** maps an array */
export function map<T, U>(array: T[], callback: (item: T) => U): U[] {
  return array.map(callback);
}

/** sums numbers projected from items */
export const sumBy = <T>(array: T[], selector: (item: T) => number): number =>
  array.reduce((sum, item) => sum + selector(item), 0);

/** multiplies numbers projected from items */
export const productBy = <T>(array: T[], selector: (item: T) => number): number =>
  array.reduce((product, item) => product * selector(item), 1);

/** immutably sets a property on an object */
export const assoc = <T extends object, K extends PropertyKey, V = unknown>(
  obj: T,
  key: K,
  value: V
): T & Record<K, V> => ({ ...(obj as object), [key]: value }) as T & Record<K, V>;

/** updates an array element at index */
export const updateAt = <T>(array: T[], index: number, updater: (item: T) => T): T[] =>
  array.map((item, i) => (i === index ? updater(item) : item));

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

/**
 * Debounces a function call by the specified delay in milliseconds.
 * Subsequent calls within the delay period will cancel and restart the timer.
 *
 * @param fn The function to debounce
 * @param delay Delay in milliseconds (default: 300ms)
 * @returns A debounced version of the function
 */
export function debounce<Args extends unknown[], R>(
  fn: (...args: Args) => R,
  delay = 300
): (...args: Args) => void {
  let timeoutId: number | undefined;

  return (...args: Args) => {
    if (timeoutId !== undefined) {
      clearTimeout(timeoutId);
    }

    timeoutId = setTimeout(() => {
      fn(...args);
      timeoutId = undefined;
    }, delay) as unknown as number;
  };
}
