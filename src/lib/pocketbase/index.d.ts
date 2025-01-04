/**
 * This file was @generated using pocketbase-typegen
 */

import type PocketBase from "pocketbase";
import type { RecordService } from "pocketbase";

export enum Collections {
  ActiveMessage = "activeMessage",
  Categories = "categories",
  DisplayMessages = "displayMessages",
  Drinks = "drinks",
  OrderDrink = "order_drink",
  Orders = "orders",
  Users = "users"
}

// Alias types for improved usability
export type IsoDateString = string;
export type RecordIdString = string;
export type HTMLString = string;

// System fields
export type BaseSystemFields<T = never> = {
  id: RecordIdString;
  created: IsoDateString;
  updated: IsoDateString;
  collectionId: string;
  collectionName: Collections;
  expand?: T;
};

export type AuthSystemFields<T = never> = {
  email: string;
  emailVisibility: boolean;
  username: string;
  verified: boolean;
} & BaseSystemFields<T>;

// Record types for each collection

export type ActiveMessageRecord = {
  isVisible?: boolean;
  message?: RecordIdString;
};

export type CategoriesRecord = {
  name: string;
  sort_order: number;
};

export type DisplayMessagesRecord = {
  subtext?: string;
  title?: string;
};

export type DrinksRecord = {
  category: RecordIdString;
  image: string;
  name: string;
  price: number;
};

export enum OrderDrinkServingSizeOptions {
  "small" = "small",
  "big" = "big",
  "custom" = "custom"
}

export enum OrderDrinkMilkOptions {
  "oat" = "oat",
  "soy" = "soy",
  "whole" = "whole",
  "low-fat" = "low-fat",
  "lactose-free" = "lactose-free"
}

export enum OrderDrinkExtrasOptions {
  "sirup" = "sirup",
  "espresso" = "espresso",
  "cream" = "cream"
}

export enum OrderDrinkFlavorOptions {
  "vanilla" = "vanilla",
  "salt-caramel" = "salt-caramel",
  "pumpkin-spice" = "pumpkin-spice",
  "irish" = "irish",
  "spicy" = "spicy"
}
export type OrderDrinkRecord = {
  drink: RecordIdString;
  extras?: OrderDrinkExtrasOptions[];
  flavor?: OrderDrinkFlavorOptions[];
  milk?: OrderDrinkMilkOptions;
  serving_size?: OrderDrinkServingSizeOptions;
};

export enum OrdersStateOptions {
  "received" = "received",
  "production" = "production",
  "completed" = "completed",
  "dispatched" = "dispatched"
}
export type OrdersRecord = {
  customer?: RecordIdString;
  drinks: RecordIdString[];
  payment_fulfilled?: boolean;
  state?: OrdersStateOptions;
};

export type UsersRecord = {
  avatar?: string;
  favorites?: RecordIdString[];
  is_admin?: boolean;
  name?: string;
  purchased_cup?: boolean;
};

// Response types include system fields and match responses from the PocketBase API
export type ActiveMessageResponse<Texpand = unknown> = Required<ActiveMessageRecord> &
  BaseSystemFields<Texpand>;
export type CategoriesResponse<Texpand = unknown> = Required<CategoriesRecord> &
  BaseSystemFields<Texpand>;
export type DisplayMessagesResponse<Texpand = unknown> = Required<DisplayMessagesRecord> &
  BaseSystemFields<Texpand>;
export type DrinksResponse<Texpand = unknown> = Required<DrinksRecord> & BaseSystemFields<Texpand>;
export type OrderDrinkResponse<Texpand = unknown> = Required<OrderDrinkRecord> &
  BaseSystemFields<Texpand>;
export type OrdersResponse<Texpand = unknown> = Required<OrdersRecord> & BaseSystemFields<Texpand>;
export type UsersResponse<Texpand = unknown> = Required<UsersRecord> & AuthSystemFields<Texpand>;

// Types containing all Records and Responses, useful for creating typing helper functions

export type CollectionRecords = {
  activeMessage: ActiveMessageRecord;
  categories: CategoriesRecord;
  displayMessages: DisplayMessagesRecord;
  drinks: DrinksRecord;
  order_drink: OrderDrinkRecord;
  orders: OrdersRecord;
  users: UsersRecord;
};

export type CollectionResponses = {
  activeMessage: ActiveMessageResponse;
  categories: CategoriesResponse;
  displayMessages: DisplayMessagesResponse;
  drinks: DrinksResponse;
  order_drink: OrderDrinkResponse;
  orders: OrdersResponse;
  users: UsersResponse;
};

// Type for usage with type asserted PocketBase instance
// https://github.com/pocketbase/js-sdk#specify-typescript-definitions

export type TypedPocketBase = PocketBase & {
  collection(idOrName: "activeMessage"): RecordService<ActiveMessageResponse>;
  collection(idOrName: "categories"): RecordService<CategoriesResponse>;
  collection(idOrName: "displayMessages"): RecordService<DisplayMessagesResponse>;
  collection(idOrName: "drinks"): RecordService<DrinksResponse>;
  collection(idOrName: "order_drink"): RecordService<OrderDrinkResponse>;
  collection(idOrName: "orders"): RecordService<OrdersResponse>;
  collection(idOrName: "users"): RecordService<UsersResponse>;
};
