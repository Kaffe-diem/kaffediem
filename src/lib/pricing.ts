import { sumBy, productBy } from "$lib/utils";
import type { CustomizationValue } from "$lib/types";

export const finalPrice = (basePrice: number, customizations: CustomizationValue[]): number => {
  const additive = sumBy(customizations, (c) => (c.constantPrice ? c.priceChange || 0 : 0));

  const multiplicative = productBy(
    customizations,
    (c) => (!c.constantPrice ? ((c.priceChange ?? 100) / 100) : 1)
  );

  return Math.ceil((basePrice + additive) * multiplicative);
};
