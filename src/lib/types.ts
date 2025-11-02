import { restrictedRoutes, adminRoutes } from "$lib/constants";

export type OrderState = "received" | "production" | "completed" | "dispatched";

export const OrderStateOptions = {
  received: "received",
  production: "production",
  completed: "completed",
  dispatched: "dispatched"
} as const satisfies Record<string, OrderState>;

export type OrderStateOptions = (typeof OrderStateOptions)[keyof typeof OrderStateOptions];
export const State = OrderStateOptions;
export type State = OrderState;

export type OrderItemCustomization = {
  key_id: string;
  key_name: string;
  value_id: string;
  value_name: string;
  price_change: number;
  label_color?: string | null;
};

export type OrderItem = {
  item_id: string;
  name: string;
  price: number;
  category: string;
  customizations: OrderItemCustomization[];
};

export type Order = {
  id: string;
  customer_id: number | null;
  day_id: number;
  state: OrderState;
  missing_information: boolean;
  items: OrderItem[];
  created?: string;
  updated?: string;
};

export type OrderItemSnapshot = OrderItem;

export type Category = {
  id: string;
  name: string;
  sort_order: number;
  enable: boolean;
  valid_customizations: string[];
  created?: string;
  updated?: string;
};

export type Item = {
  id: string;
  name: string;
  price_nok: number;
  category: string;
  image: string | null;
  enable: boolean;
  sort_order: number;
  created?: string;
  updated?: string;
  imageFile?: File | null;
};

export type CustomizationKey = {
  id: string;
  name: string;
  enable: boolean;
  label_color: string | null;
  default_value: string | null;
  multiple_choice: boolean;
  sort_order: number;
  created?: string;
  updated?: string;
};

export type CustomizationValue = {
  id: string;
  name: string;
  price_increment_nok: number;
  constant_price: boolean;
  belongs_to: string;
  enable: boolean;
  sort_order: number;
  created?: string;
  updated?: string;
};

export type Message = {
  id: string;
  title: string;
  subtitle: string | null;
  created?: string;
  updated?: string;
};

export type Status = {
  id: string;
  open: boolean;
  show_message: boolean;
  message: string | null;
  created?: string;
  updated?: string;
};

export type User = {
  id: string;
  name: string;
  isAdmin: boolean;
};

type NavRoutes = "/account" | "/admin";

export class NavItem {
  href: NavRoutes;
  text: string;
  requiresAuth: boolean;
  requiresAdmin: boolean;

  constructor(href: NavRoutes, text: string) {
    this.href = href;
    this.text = text;
    this.requiresAuth = restrictedRoutes.includes(href);
    this.requiresAdmin = adminRoutes.includes(href);
  }
}

export function itemToApi(item: Item): FormData | Record<string, unknown> {
  if (item.imageFile) {
    const formData = new FormData();
    formData.append("name", item.name);
    formData.append("price_nok", item.price_nok.toString());
    formData.append("category", item.category);
    formData.append("enable", item.enable.toString());
    formData.append("sort_order", item.sort_order.toString());
    formData.append("image", item.imageFile);
    return formData;
  }

  return {
    name: item.name,
    price_nok: item.price_nok,
    category: item.category,
    enable: item.enable,
    sort_order: item.sort_order,
    image: item.image
  };
}

export function userFromBackend(
  data: { id?: string; name?: string; is_admin?: boolean } | null
): User {
  if (!data) {
    return { id: "", name: "", isAdmin: false };
  }
  return {
    id: data.id ?? "",
    name: data.name ?? "",
    isAdmin: data.is_admin ?? false
  };
}
