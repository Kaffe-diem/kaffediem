import { createGenericPbStore } from "$stores/pbStore";
import { Collections } from "$lib/pocketbase";
import { Item, Category } from "$lib/types";

export const categories = createGenericPbStore(Collections.Categories, Category, {
  sort: "sort_order",
  expand: "drinks_via_category"
});

export const items = createGenericPbStore(Collections.Drinks, Item);
