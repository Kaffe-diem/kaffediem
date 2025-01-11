import { createGenericPbStore } from "$stores/pbStore";
import { Collections } from "$lib/pocketbase";
import { Item, Category } from "$lib/types";

export const categories = createGenericPbStore(Collections.Category, Category, {
  sort: "sort_order",
  expand: "item_via_category"
});

export const items = createGenericPbStore(Collections.Item, Item);
