import { sumBy, productBy } from "$lib/utils";
import type { CustomizationValue } from "$lib/types";

export const finalPrice = (basePrice: number, customizations: CustomizationValue[]): number => {
  const additive = sumBy(customizations, (c) =>
    c.constant_price ? c.price_increment_nok || 0 : 0
  );

  const multiplicative = productBy(customizations, (c) =>
    c.constant_price ? 1 : (c.price_increment_nok ?? 100) / 100
  );

  return Math.ceil((basePrice + additive) * multiplicative);
};
