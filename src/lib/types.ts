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

// Collection names enum
export enum Collections {
  Category = "category",
  CustomizationKey = "customization_key",
  CustomizationValue = "customization_value",
  Item = "item",
  ItemCustomization = "item_customization",
  Message = "message",
  Order = "order",
  Status = "status",
  User = "user"
}

// data transfer objects for backend communication
export type OrderDTO = {
  id: string;
  customer_id: number | null;
  day_id: number;
  state: OrderState;
  missing_information: boolean;
  items: {
    item_id: string;
    name: string;
    price: number;
    category: string;
    customizations: {
      key_id: string;
      key_name: string;
      value_id: string;
      value_name: string;
      price_change: number;
    }[];
  }[];
  created?: string;
  updated?: string;
};

export type CategoryDTO = {
  id: string;
  name: string;
  sort_order: number;
  enable: boolean;
  valid_customizations: string[];
  created?: string;
  updated?: string;
};

export type ItemDTO = {
  id: string;
  name: string;
  price_nok: number;
  category: string;
  image: string | null;
  enable: boolean;
  sort_order: number;
  created?: string;
  updated?: string;
};

export type CustomizationKeyDTO = {
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

export type CustomizationValueDTO = {
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


export type MessageDTO = {
  id: string;
  title: string;
  subtitle: string | null;
  created?: string;
  updated?: string;
};

export type StatusDTO = {
  id: string;
  open: boolean;
  show_message: boolean;
  message: string | null;
  created?: string;
  updated?: string;
};

export type UserDTO = {
  id: string;
  email: string;
  name: string | null;
  username: string | null;
  is_admin: boolean;
  created?: string;
  updated?: string;
};

// Frontend types
export type Order = {
  id: string;
  customerId: number | null;
  dayId: number;
  state: OrderState;
  missingInformation: boolean;
  items: {
    itemId: string;
    name: string;
    price: number;
    category: string;
    customizations: {
      keyId: string;
      keyName: string;
      valueId: string;
      valueName: string;
      priceChange: number;
    }[];
  }[];
  createdAt?: string;
  updatedAt?: string;
};

export type OrderItemSnapshot = Order["items"][number];

export type Category = {
  id: string;
  name: string;
  sortOrder: number;
  enabled: boolean;
  validCustomizations: string[];
};

export type Item = {
  id: string;
  name: string;
  price: number;
  category: string;
  image: string;
  enabled: boolean;
  sortOrder: number;
  imageFile?: File; // for uploads
};

export type CustomizationKey = {
  id: string;
  name: string;
  enabled: boolean;
  labelColor: string;
  defaultValue: string;
  multipleChoice: boolean;
  sortOrder: number;
};

export type CustomizationValue = {
  id: string;
  name: string;
  priceChange: number;
  constantPrice: boolean;
  belongsTo: string;
  enabled: boolean;
  sortOrder: number;
};


export type Message = {
  id: string;
  title: string;
  subtitle: string | null;
};

export type Status = {
  id: string;
  open: boolean;
  showMessage: boolean;
  messageId: string | null;
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

// conversion helpers
export function orderFromApi(dto: OrderDTO): Order {
  return {
    id: dto.id,
    customerId: dto.customer_id,
    dayId: dto.day_id,
    state: dto.state,
    missingInformation: dto.missing_information,
    items: dto.items.map((item) => ({
      itemId: item.item_id,
      name: item.name,
      price: item.price,
      category: item.category,
      customizations: item.customizations.map((c) => ({
        keyId: c.key_id,
        keyName: c.key_name,
        valueId: c.value_id,
        valueName: c.value_name,
        priceChange: c.price_change
      }))
    })),
    createdAt: dto.created,
    updatedAt: dto.updated
  };
}

export function categoryFromApi(dto: CategoryDTO): Category {
  return {
    id: dto.id,
    name: dto.name,
    sortOrder: dto.sort_order,
    enabled: dto.enable,
    validCustomizations: dto.valid_customizations
  };
}

export function categoryToApi(cat: Category): Partial<CategoryDTO> {
  return {
    name: cat.name,
    sort_order: cat.sortOrder,
    enable: cat.enabled,
    valid_customizations: cat.validCustomizations
  };
}

export function itemFromApi(dto: ItemDTO): Item {
  return {
    id: dto.id,
    name: dto.name,
    price: dto.price_nok,
    category: dto.category,
    image: dto.image || "",
    enabled: dto.enable,
    sortOrder: dto.sort_order
  };
}

export function itemToApi(item: Item): FormData | Record<string, unknown> {
  if (item.imageFile) {
    const formData = new FormData();
    formData.append("name", item.name);
    formData.append("price_nok", item.price.toString());
    formData.append("category", item.category);
    formData.append("enable", item.enabled.toString());
    formData.append("sort_order", item.sortOrder.toString());
    formData.append("image", item.imageFile);
    return formData;
  }

  return {
    name: item.name,
    price_nok: item.price,
    category: item.category,
    enable: item.enabled,
    sort_order: item.sortOrder,
    image: item.image
  };
}

export function customizationKeyFromApi(dto: CustomizationKeyDTO): CustomizationKey {
  return {
    id: dto.id,
    name: dto.name,
    enabled: dto.enable,
    labelColor: dto.label_color ?? "",
    defaultValue: dto.default_value ?? "",
    multipleChoice: dto.multiple_choice,
    sortOrder: dto.sort_order
  };
}

export function customizationKeyToApi(key: CustomizationKey): Partial<CustomizationKeyDTO> {
  return {
    name: key.name,
    enable: key.enabled,
    label_color: key.labelColor,
    default_value: key.defaultValue,
    multiple_choice: key.multipleChoice,
    sort_order: key.sortOrder
  };
}

export function customizationValueFromApi(dto: CustomizationValueDTO): CustomizationValue {
  return {
    id: dto.id,
    name: dto.name,
    priceChange: dto.price_increment_nok,
    constantPrice: dto.constant_price,
    belongsTo: dto.belongs_to,
    enabled: dto.enable,
    sortOrder: dto.sort_order
  };
}

export function customizationValueToApi(val: CustomizationValue): Partial<CustomizationValueDTO> {
  return {
    name: val.name,
    price_increment_nok: val.priceChange,
    constant_price: val.constantPrice,
    belongs_to: val.belongsTo,
    enable: val.enabled,
    sort_order: val.sortOrder
  };
}


export function messageFromApi(dto: MessageDTO): Message {
  return {
    id: dto.id,
    title: dto.title,
    subtitle: dto.subtitle
  };
}

export function messageToApi(msg: Message): Partial<MessageDTO> {
  return {
    title: msg.title,
    subtitle: msg.subtitle || null
  };
}

export function statusFromApi(dto: StatusDTO): Status {
  return {
    id: dto.id,
    open: dto.open,
    showMessage: dto.show_message,
    messageId: dto.message
  };
}

export function statusToApi(status: Status): Partial<StatusDTO> {
  return {
    open: status.open,
    show_message: status.showMessage,
    message: status.messageId
  };
}

// User helper for auth - handle null/partial data
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
