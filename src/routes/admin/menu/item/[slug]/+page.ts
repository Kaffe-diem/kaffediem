import type { PageLoad } from "./$types";

export const load: PageLoad = ({ params }) => {
  const id = params.slug;
  return { id };
};
