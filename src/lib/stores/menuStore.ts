import { derived, get } from "svelte/store";
import { createCollectionCrud } from "$stores/websocketStore";
import { Collections } from "$lib/types";
import {
  Item,
  Category,
  CustomizationKey,
  CustomizationValue,
  ItemCustomization
} from "$lib/types";

export const categories = createCollectionCrud(Collections.Category, {
  fromWire: Category.fromApi
});

export const getCategoryById = (categoryId: string): Category | undefined => {
  return get(categories).find((value) => value.id === categoryId);
};

export const items = createCollectionCrud(Collections.Item, {
  fromWire: Item.fromApi
});

export const itemsByCategory = derived(items, ($items) =>
  $items.reduce((acc: Record<string, Item[]>, item: Item) => {
    acc[item.category] ||= [];
    acc[item.category]!.push(item);
    return acc;
  }, {})
);

export const customizationKeys = createCollectionCrud(Collections.CustomizationKey, {
  fromWire: CustomizationKey.fromApi
});

export const customizationValues = createCollectionCrud(Collections.CustomizationValue, {
  fromWire: CustomizationValue.fromApi
});

export const customizationsByKey = derived(customizationValues, ($customizationValues) =>
  $customizationValues.reduce((acc: Record<string, CustomizationValue[]>, item) => {
    acc[item.belongsTo] ||= [];
    acc[item.belongsTo]!.push(item);
    return acc;
  }, {})
);

export const itemCustomizations = createCollectionCrud(Collections.ItemCustomization, {
  fromWire: ItemCustomization.fromApi
});
