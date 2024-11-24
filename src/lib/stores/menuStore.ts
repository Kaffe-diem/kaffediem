import createPbStore from "$stores/pbStore";
import pb from "$lib/pocketbase";
import { Item, Category } from "$lib/types";

const mapToItem = (data: {
  id: string;
  name: string;
  price: number;
  category: string;
  image: string;
}): Item =>
  new Item({
    id: data.id,
    name: data.name,
    price: data.price,
    category: data.category,
    image: pb.files.getUrl(data, data.image)
  });
const mapToCategory = (data: {
  id: string;
  name: string;
  sort_order: number;
  // FIXME: again, pocketbase typing
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  expand: any;
}): Category =>
  new Category({
    id: data.id,
    name: data.name,
    sortOrder: data.sort_order,
    items: data.expand.drinks_via_category.map(mapToItem)
  });

export const categories = {
  subscribe: createPbStore<Category>("categories", mapToCategory, {
    sort: "sort_order",
    expand: "drinks_via_category"
  }),
  update: async (category: Category) => {
    await pb.collection("categories").update(category.id, {
      name: category.name,
      sort_order: category.sortOrder
    });
  },
  create: async (category: Category) => {
    await pb.collection("categories").create({
      name: category.name,
      sort_order: category.sortOrder
    });
  },
  delete: async (id: string) => {
    await pb.collection("categories").delete(id);
  }
};

export const items = {
  subscribe: createPbStore<Item>("drinks", mapToItem),
  update: async (item: Item) => {
    await pb.collection("drinks").update(item.id, {
      name: item.name,
      price: item.price,
      category: item.category
    });
  },
  create: async (item: Item) => {
    await pb.collection("drinks").create({
      name: item.name,
      price: item.price,
      category: item.category
    });
  },
  delete: async (id: string) => {
    await pb.collection("drinks").delete(id);
  }
};
