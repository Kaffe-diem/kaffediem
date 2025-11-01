import { derived } from "svelte/store";
import { createChannelStore, createCrudOperations } from "./collection";
import type { Category, Item, CustomizationKey, CustomizationValue } from "$lib/types";
import { itemToApi } from "$lib/types";

export type MenuCustomization = {
  key: CustomizationKey;
  values: CustomizationValue[];
};

export type MenuItem = Item & {
  customizations: MenuCustomization[];
};

export type MenuCategory = Category & {
  items: MenuItem[];
};

export type MenuIndexes = {
  categories: Category[];
  items: Item[];
  items_by_category: Record<string, Item[]>;
  customization_keys: CustomizationKey[];
  customization_values: CustomizationValue[];
  customizations_by_key: Record<string, CustomizationValue[]>;
};

export type MenuPayload = {
  tree: MenuCategory[];
  indexes: MenuIndexes;
};

// we set this to have valid data before hydration
const emptyMenu: MenuPayload = {
  tree: [],
  indexes: {
    categories: [],
    items: [],
    items_by_category: {},
    customization_keys: [],
    customization_values: [],
    customizations_by_key: {}
  }
};

export const menu = createChannelStore<MenuPayload>("menu", {
  initialValue: emptyMenu,
  extract: (response: unknown) => toMenuPayload((response as { items?: unknown })?.items)
});

export const menuTree = derived(menu, ($menu) => $menu.tree);
export const menuIndexes = derived(menu, ($menu) => $menu.indexes);

export const {
  create: createCategory,
  update: updateCategory,
  delete: deleteCategory
} = createCrudOperations<Category>("category");

export const {
  create: createItem,
  update: updateItem,
  delete: deleteItem
} = createCrudOperations("item", { toApi: itemToApi });

export const {
  create: createCustomizationKey,
  update: updateCustomizationKey,
  delete: deleteCustomizationKey
} = createCrudOperations<CustomizationKey>("customization_key");

export const {
  create: createCustomizationValue,
  update: updateCustomizationValue,
  delete: deleteCustomizationValue
} = createCrudOperations<CustomizationValue>("customization_value");

export function destroyMenuChannel() {
  menu.destroy();
}

function toMenuPayload(payload: unknown): MenuPayload {
  if (payload && typeof payload === "object") {
    const { tree, indexes } = payload as { tree?: unknown; indexes?: MenuIndexes };
    if (Array.isArray(tree)) {
      return {
        tree: tree as MenuCategory[],
        indexes: indexes ?? emptyMenu.indexes
      };
    }
  }

  console.warn("Unexpected menu payload", payload);
  return emptyMenu;
}
