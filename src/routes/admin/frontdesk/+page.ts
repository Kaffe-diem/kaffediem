import pb from "$lib/pocketbase";

export const load = async ({ fetch }) => {
  // Sorting by relations does not work: https://github.com/pocketbase/pocketbase/discussions/1429
  // Has to be done after fetching (if required)
  const categories = await pb.collection("categories").getFullList({
    sort: "sort_order",
    // Expansion limited to 1000, which likely won't be a problem here
    expand: "drinks_via_category",
    fetch
  });

  return { categories };
};
