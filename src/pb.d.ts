/**
* This file was @generated using pocketbase-typegen
*/

import type PocketBase from 'pocketbase'
import type { RecordService } from 'pocketbase'

export enum Collections {
	Drinks = "drinks",
	OrderDrink = "order_drink",
	Orders = "orders",
	ScreenMessage = "screen_message",
	Users = "users",
}

// Alias types for improved usability
export type IsoDateString = string
export type RecordIdString = string
export type HTMLString = string

// System fields
export type BaseSystemFields<T = never> = {
	id: RecordIdString
	created: IsoDateString
	updated: IsoDateString
	collectionId: string
	collectionName: Collections
	expand?: T
}

export type AuthSystemFields<T = never> = {
	email: string
	emailVisibility: boolean
	username: string
	verified: boolean
} & BaseSystemFields<T>

// Record types for each collection

export enum DrinksKindOptions {
	"hot" = "hot",
	"cold" = "cold",
	"special" = "special",
}
export type DrinksRecord = {
	image?: string
	kind?: DrinksKindOptions
	name?: string
	price?: number
}

export enum OrderDrinkServingSizeOptions {
	"small" = "small",
	"big" = "big",
	"custom" = "custom",
}

export enum OrderDrinkMilkOptions {
	"oat" = "oat",
	"soy" = "soy",
	"whole" = "whole",
	"low-fat" = "low-fat",
	"lactose-free" = "lactose-free",
}

export enum OrderDrinkExtrasOptions {
	"sirup" = "sirup",
	"espresso" = "espresso",
	"cream" = "cream",
}

export enum OrderDrinkFlavorOptions {
	"vanilla" = "vanilla",
	"salt-caramel" = "salt-caramel",
	"pumpkin-spice" = "pumpkin-spice",
	"irish" = "irish",
	"spicy" = "spicy",
}
export type OrderDrinkRecord = {
	drink: RecordIdString
	extras?: OrderDrinkExtrasOptions[]
	flavor?: OrderDrinkFlavorOptions[]
	milk: OrderDrinkMilkOptions
	order: RecordIdString
	serving_size: OrderDrinkServingSizeOptions
}

export type OrdersRecord = {
	customer: RecordIdString
	drinks: RecordIdString[]
	order_fulfilled?: boolean
	payment_fulfilled?: boolean
}

export type ScreenMessageRecord = {
	subtext?: string
	title?: string
}

export type UsersRecord = {
	avatar?: string
	favorites?: RecordIdString[]
	name?: string
	purchased_cup?: boolean
}

// Response types include system fields and match responses from the PocketBase API
export type DrinksResponse<Texpand = unknown> = Required<DrinksRecord> & BaseSystemFields<Texpand>
export type OrderDrinkResponse<Texpand = unknown> = Required<OrderDrinkRecord> & BaseSystemFields<Texpand>
export type OrdersResponse<Texpand = unknown> = Required<OrdersRecord> & BaseSystemFields<Texpand>
export type ScreenMessageResponse<Texpand = unknown> = Required<ScreenMessageRecord> & BaseSystemFields<Texpand>
export type UsersResponse<Texpand = unknown> = Required<UsersRecord> & AuthSystemFields<Texpand>

// Types containing all Records and Responses, useful for creating typing helper functions

export type CollectionRecords = {
	drinks: DrinksRecord
	order_drink: OrderDrinkRecord
	orders: OrdersRecord
	screen_message: ScreenMessageRecord
	users: UsersRecord
}

export type CollectionResponses = {
	drinks: DrinksResponse
	order_drink: OrderDrinkResponse
	orders: OrdersResponse
	screen_message: ScreenMessageResponse
	users: UsersResponse
}

// Type for usage with type asserted PocketBase instance
// https://github.com/pocketbase/js-sdk#specify-typescript-definitions

export type TypedPocketBase = PocketBase & {
	collection(idOrName: 'drinks'): RecordService<DrinksResponse>
	collection(idOrName: 'order_drink'): RecordService<OrderDrinkResponse>
	collection(idOrName: 'orders'): RecordService<OrdersResponse>
	collection(idOrName: 'screen_message'): RecordService<ScreenMessageResponse>
	collection(idOrName: 'users'): RecordService<UsersResponse>
}
