import createPbStore from "$stores/pbStore";
import pb from "$lib/pocketbase";
import {
  Collections,
  type CategoriesResponse,
  type DrinksResponse,
  type RecordIdString,
  type DrinksViaCategory
} from "$lib/pb.d";

type CategoryWithDrinks = CategoriesResponse<{
  drinks_via_category: DrinksViaCategory[];
}>;

export const categories = {
  subscribe: createPbStore(Collections.Categories, {
    sort: "sort_order",
    expand: "drinks_via_category"
  }),

  update: async (category: CategoryWithDrinks) => {
    await pb.collection(Collections.Categories).update(category.id, {
      name: category.name,
      sort_order: category.sort_order
    });
  },

  create: async (category: Omit<CategoryWithDrinks, "expand">) => {
    await pb.collection(Collections.Categories).create({
      name: category.name,
      sort_order: category.sort_order
    });
  },

  delete: async (id: string) => {
    await pb.collection(Collections.Categories).delete(id);
  }
};

export const items = {
  subscribe: createPbStore(Collections.Drinks),

  update: async (item: DrinksResponse) => {
    await pb.collection(Collections.Drinks).update(item.id, {
      name: item.name,
      price: item.price,
      category: item.category
    });
  },

  create: async (item: DrinksResponse) => {
    await pb.collection(Collections.Drinks).create({
      name: item.name,
      price: item.price,
      category: item.category
    });
  },

  delete: async (id: RecordIdString) => {
    await pb.collection(Collections.Drinks).delete(id);
  }
};
