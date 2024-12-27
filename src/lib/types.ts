import {
  type RecordIdString,
  OrdersStateOptions,
  type DrinksResponse,
  type ActiveMessageResponse,
  type OrderDrinkResponse,
  type OrdersResponse,
  type BaseSystemFields
} from "$lib/pocketbase";
import { restrictedRoutes, adminRoutes } from "$lib/constants";

export function makeNavItem(href: string, text: string) {
  return {
    href,
    text,
    requiresAuth: restrictedRoutes.includes(href),
    requiresAdmin: adminRoutes.includes(href)
  };
}

export type NavItem = ReturnType<typeof makeNavItem>;

type State = OrdersStateOptions;
export { OrdersStateOptions as State };

export function makeRecord(data: { id: RecordIdString }) {
  return {
    id: data.id
  };
}

export function makeOrderItem(data: { id: RecordIdString; name: string; item: Item }) {
  return {
    ...makeRecord(data),
    name: data.name,
    item: data.item
  };
}

export function makeItem(data: {
  id: RecordIdString;
  name: string;
  price: number;
  category: string;
  image: string;
}) {
  return {
    ...makeRecord(data),
    name: data.name,
    price: data.price,
    category: data.category,
    image: data.image
  };
}

export function makeCategory(data: {
  id: RecordIdString;
  name: string;
  sortOrder: number;
  items: Item[];
}) {
  return {
    ...makeRecord(data),
    name: data.name,
    sortOrder: data.sortOrder,
    items: data.items
  };
}

// messages
export type Message = ReturnType<typeof makeMessage>;

export function makeMessage(data: { id: RecordIdString; title: string; subtext: string }) {
  return {
    ...makeRecord(data),
    title: data.title,
    subtext: data.subtext
  };
}

export type ExpandedActiveMessageRecord = ActiveMessageResponse & {
  expand: { message: Message };
};

export function makeActiveMessage(data: {
  id: RecordIdString;
  message: Message;
  visible: boolean;
}) {
  return {
    ...makeRecord(data),
    message: data.message,
    visible: data.visible
  };
}

export type ActiveMessage = ReturnType<typeof makeActiveMessage>;

export type Record = ReturnType<typeof makeRecord>;
export type OrderItem = ReturnType<typeof makeOrderItem>;
export type Item = ReturnType<typeof makeItem>;
export type Category = ReturnType<typeof makeCategory>;

export type Order = {
  id: RecordIdString;
  state: State;
  items: Array<OrderItem>;
};

export function makeOrder(data: BaseSystemFields<unknown>): Order {
  const expandedData = data as OrdersResponse & {
    expand?: { drinks: Array<OrderDrinkResponse & { expand?: { drink: DrinksResponse } }> };
  };

  return {
    id: expandedData.id,
    state: expandedData.state,
    items:
      expandedData.expand?.drinks?.map((drink) => ({
        id: drink.id,
        name: drink.expand?.drink?.name || "",
        item: {
          id: drink.expand?.drink?.id || "",
          name: drink.expand?.drink?.name || "",
          price: drink.expand?.drink?.price || 0,
          category: drink.expand?.drink?.category || "",
          image: drink.expand?.drink?.image || ""
        }
      })) || []
  };
}
