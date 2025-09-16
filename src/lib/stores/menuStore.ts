import { derived } from "svelte/store";
import { createGenericPbStore } from "$stores/pbStore";
import { Collections } from "$lib/pocketbase";
import {
  Item,
  Category,
  CustomizationKey,
  CustomizationValue,
  ItemCustomization
} from "$lib/types";

export const categories = await createGenericPbStore(Collections.Category, Category, {
  sort: "sort_order"
});

export const items = await createGenericPbStore(Collections.Item, Item);

export const itemsByCategory = derived(items, ($items) =>
  $items.reduce((acc: Record<string, Item[]>, item: Item) => {
    acc[item.category] ||= [];
    acc[item.category]!.push(item);
    return acc;
  }, {})
);

export const customizationKeys = await createGenericPbStore(
  Collections.CustomizationKey,
  CustomizationKey
);
export const customizationValues = await createGenericPbStore(
  Collections.CustomizationValue,
  CustomizationValue
);
export const customizationsByKey = derived(customizationValues, ($customizationValues) =>
  $customizationValues.reduce((acc: Record<string, CustomizationValue[]>, item) => {
    acc[item.belongsTo] ||= [];
    acc[item.belongsTo]!.push(item);
    return acc;
  }, {})
);

export const itemCustomizations = await createGenericPbStore(
  Collections.ItemCustomization,
  ItemCustomization,
  {
    expand: "key,value"
  }
);
