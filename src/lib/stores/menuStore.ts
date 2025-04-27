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
  sort: "sort_order"
});

export const items = createGenericPbStore(Collections.Item, Item);

export const customizationKeys = createGenericPbStore(
  Collections.CustomizationKey,
  CustomizationKey
);
export const customizationValues = createGenericPbStore(
  Collections.CustomizationValue,
  CustomizationValue
);
export const itemCustomizations = createGenericPbStore(
  Collections.ItemCustomization,
  ItemCustomization,
  {
    expand: "key,value"
  }
);
