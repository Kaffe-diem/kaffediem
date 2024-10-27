import { pb } from "$lib/stores/authStore";

export const load = async ({ fetch }) => {
  const drinks = await pb.collection("drinks").getFullList({
    sort: "-created",
    fetch
  });
  const categories = await pb.collection("categories").getFullList({
    sort: "sort_order",
    fetch
  });

  return {
    drinks: Object.groupBy(drinks, ({ kind }) => kind),
    categories
  };
};
