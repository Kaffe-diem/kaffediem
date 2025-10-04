/**
 * Typed contract for the Kaffebase API. Extracted from the previous
 * `$lib/pocketbase` type definitions so it can live alongside runtime code.
 */
export enum Collections {
  Authorigins = "_authOrigins",
  Externalauths = "_externalAuths",
  Mfas = "_mfas",
  Otps = "_otps",
  Superusers = "_superusers",
  Category = "category",
  CustomizationKey = "customization_key",
  CustomizationValue = "customization_value",
  Item = "item",
  ItemCustomization = "item_customization",
  Message = "message",
  Order = "order",
  OrderItem = "order_item",
  Status = "status",
  User = "user"
}

export type IsoDateString = string;
export type RecordIdString = string;
export type HTMLString = string;

type ExpandType<T> = unknown extends T
  ? T extends unknown
    ? { expand?: unknown }
    : { expand: T }
  : { expand: T };

export type BaseSystemFields<T = unknown> = {
  id: RecordIdString;
  collectionId: string;
  collectionName: Collections;
} & ExpandType<T>;

export type AuthSystemFields<T = unknown> = {
  email: string;
  emailVisibility: boolean;
  username: string;
  verified: boolean;
} & BaseSystemFields<T>;

export type CategoryRecord = {
  created?: IsoDateString;
  enable?: boolean;
  id: string;
  name: string;
  sort_order: number;
  updated?: IsoDateString;
  valid_customizations?: RecordIdString[];
};

export type CustomizationKeyRecord = {
  created?: IsoDateString;
  default_value?: RecordIdString;
  enable?: boolean;
  id: string;
  label_color: string;
  multiple_choice?: boolean;
  name: string;
  sort_order?: number;
  updated?: IsoDateString;
};

export type CustomizationValueRecord = {
  belongs_to: RecordIdString;
  constant_price?: boolean;
  created?: IsoDateString;
  enable?: boolean;
  id: string;
  name: string;
  price_increment_nok?: number;
  sort_order?: number;
  updated?: IsoDateString;
};

export type ItemRecord = {
  category: RecordIdString;
  created?: IsoDateString;
  enable?: boolean;
  id: string;
  image?: string;
  name: string;
  price_nok: number;
  sort_order?: number;
  updated?: IsoDateString;
};

export type ItemCustomizationRecord = {
  created?: IsoDateString;
  id: string;
  key: RecordIdString;
  updated?: IsoDateString;
  value: RecordIdString[];
};

export type MessageRecord = {
  created?: IsoDateString;
  id: string;
  subtitle?: string;
  title?: string;
  updated?: IsoDateString;
};

export enum OrderStateOptions {
  received = "received",
  production = "production",
  completed = "completed",
  dispatched = "dispatched"
}

export type OrderRecord = {
  created?: IsoDateString;
  customer?: RecordIdString;
  day_id?: number;
  id: string;
  items: RecordIdString[];
  missing_information?: boolean;
  state: OrderStateOptions;
  updated?: IsoDateString;
};

export type OrderItemRecord = {
  created?: IsoDateString;
  customization?: RecordIdString[];
  id: string;
  item: RecordIdString;
  updated?: IsoDateString;
};

export type StatusRecord = {
  created?: IsoDateString;
  id: string;
  message?: RecordIdString;
  open?: boolean;
  show_message?: boolean;
  updated?: IsoDateString;
};

export type UserRecord = {
  avatar?: string;
  created?: IsoDateString;
  email?: string;
  emailVisibility?: boolean;
  id: string;
  is_admin?: boolean;
  name?: string;
  password: string;
  tokenKey: string;
  updated?: IsoDateString;
  username: string;
  verified?: boolean;
};

export type CategoryResponse<Texpand = unknown> = Required<CategoryRecord> & BaseSystemFields<Texpand>;
export type CustomizationKeyResponse<Texpand = unknown> =
  Required<CustomizationKeyRecord> & BaseSystemFields<Texpand>;
export type CustomizationValueResponse<Texpand = unknown> =
  Required<CustomizationValueRecord> & BaseSystemFields<Texpand>;
export type ItemResponse<Texpand = unknown> = Required<ItemRecord> & BaseSystemFields<Texpand>;
export type ItemCustomizationResponse<Texpand = unknown> =
  Required<ItemCustomizationRecord> & BaseSystemFields<Texpand>;
export type MessageResponse<Texpand = unknown> = Required<MessageRecord> & BaseSystemFields<Texpand>;
export type OrderResponse<Texpand = unknown> = Required<OrderRecord> & BaseSystemFields<Texpand>;
export type OrderItemResponse<Texpand = unknown> = Required<OrderItemRecord> & BaseSystemFields<Texpand>;
export type StatusResponse<Texpand = unknown> = Required<StatusRecord> & BaseSystemFields<Texpand>;
export type UserResponse<Texpand = unknown> = Required<UserRecord> & AuthSystemFields<Texpand>;
