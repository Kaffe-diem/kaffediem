import { derived, get } from "svelte/store";
import { createGenericPbStore } from "$stores/pbStore";
import { Collections } from "$lib/pocketbase";
import {
  Item,
  Category,
  CustomizationKey,
  CustomizationValue,
  ItemCustomization
} from "$lib/types";

export const categories = createGenericPbStore(Collections.Category, Category, {
  sort: "sort_order, name"
});

export const getCategoryById = (categoryId: string): Category | undefined => {
  return get(categories).find((value) => value.id === categoryId);
};

export const items = createGenericPbStore(Collections.Item, Item, {
  sort: "sort_order, name"
});

export const itemsByCategory = derived(items, ($items) =>
  $items.reduce((acc: Record<string, Item[]>, item: Item) => {
    acc[item.category] ||= [];
    acc[item.category]!.push(item);
    return acc;
  }, {})
);

export const customizationKeys = createGenericPbStore(
  Collections.CustomizationKey,
  CustomizationKey,
  { sort: "sort_order, name" }
);
export const customizationValues = createGenericPbStore(
  Collections.CustomizationValue,
  CustomizationValue,
  {
    sort: "sort_order, name"
  }
);
export const customizationsByKey = derived(customizationValues, ($customizationValues) =>
  $customizationValues.reduce((acc: Record<string, CustomizationValue[]>, item) => {
    acc[item.belongsTo] ||= [];
    acc[item.belongsTo]!.push(item);
    return acc;
  }, {})
);

export const itemCustomizations = createGenericPbStore(
  Collections.ItemCustomization,
  ItemCustomization,
  {
    expand: "key,value"
  }
);
