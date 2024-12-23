import createPbStore from "$stores/pbStore";
import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { Item, Category } from "$lib/types";

export const categories = {
  subscribe: createPbStore(Collections.Categories, Category, {
    sort: "sort_order",
    expand: "drinks_via_category"
  }),

  update: async (category: Category) => {
    await pb.collection(Collections.Categories).update(category.id, {
      name: category.name,
      sort_order: category.sortOrder
    });
  },

  create: async (category: Category) => {
    await pb.collection(Collections.Categories).create({
      name: category.name,
      sort_order: category.sortOrder
    });
  },

  delete: async (id: RecordIdString) => {
    await pb.collection(Collections.Categories).delete(id);
  }
};

export const items = {
  subscribe: createPbStore(Collections.Drinks, Item),

  update: async (item: Item) => {
    await pb.collection(Collections.Drinks).update(item.id, {
      name: item.name,
      price: item.price,
      category: item.category
    });
  },

  create: async (item: Item) => {
    await pb.collection(Collections.Drinks).create({
      name: item.name,
      price: item.price,
      category: item.category
    });
  },

  delete: async (itemId: RecordIdString) => {
    await pb.collection(Collections.Drinks).delete(itemId);
  }
};
