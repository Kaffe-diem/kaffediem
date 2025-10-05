export enum Collections {
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

export enum OrderStateOptions {
  received = "received",
  production = "production",
  completed = "completed",
  dispatched = "dispatched"
}

export type CategoryDTO = {
  id: RecordIdString;
  name: string;
  sort_order: number;
  enable: boolean;
  valid_customizations: RecordIdString[];
  created?: IsoDateString;
  updated?: IsoDateString;
};

export type ItemDTO = {
  id: RecordIdString;
  name: string;
  price_nok: number;
  category: RecordIdString;
  image: string | null;
  enable: boolean;
  sort_order: number;
  created?: IsoDateString;
  updated?: IsoDateString;
};

export type CustomizationKeyDTO = {
  id: RecordIdString;
  name: string;
  enable: boolean;
  label_color: string | null;
  default_value: string | null;
  multiple_choice: boolean;
  sort_order: number;
  created?: IsoDateString;
  updated?: IsoDateString;
};

export type CustomizationValueDTO = {
  id: RecordIdString;
  name: string;
  price_increment_nok: number;
  constant_price: boolean;
  belongs_to: RecordIdString;
  enable: boolean;
  sort_order: number;
  created?: IsoDateString;
  updated?: IsoDateString;
};

export type ItemCustomizationDTO = {
  id: RecordIdString;
  key_id: RecordIdString;
  value_ids: RecordIdString[];
  key?: CustomizationKeyDTO | null;
  values?: CustomizationValueDTO[];
  created?: IsoDateString;
  updated?: IsoDateString;
};

export type MessageDTO = {
  id: RecordIdString;
  title: string;
  subtitle: string;
  created?: IsoDateString;
  updated?: IsoDateString;
};

export type StatusDTO = {
  id: RecordIdString;
  open: boolean;
  show_message: boolean;
  message_id: RecordIdString | null;
  message?: MessageDTO | null;
  created?: IsoDateString;
  updated?: IsoDateString;
};

export type OrderItemDTO = {
  id: RecordIdString;
  item_id: RecordIdString;
  customization_ids: RecordIdString[];
  item?: ItemDTO | null;
  customizations: ItemCustomizationDTO[];
  created?: IsoDateString;
  updated?: IsoDateString;
};

export type OrderDTO = {
  id: RecordIdString;
  customer_id: RecordIdString | null;
  day_id: number;
  state: OrderStateOptions;
  missing_information: boolean;
  order_item_ids: RecordIdString[];
  items: OrderItemDTO[];
  created?: IsoDateString;
  updated?: IsoDateString;
};

export type UserDTO = {
  id: RecordIdString;
  email: string;
  name: string | null;
  username: string | null;
  is_admin: boolean;
  created?: IsoDateString;
  updated?: IsoDateString;
};
