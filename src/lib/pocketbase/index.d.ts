/**
* This file was @generated using pocketbase-typegen
*/

import type PocketBase from 'pocketbase'
import type { RecordService } from 'pocketbase'

export enum Collections {
	Authorigins = "_authOrigins",
	Externalauths = "_externalAuths",
	Mfas = "_mfas",
	Otps = "_otps",
	Superusers = "_superusers",
	ActiveMessage = "activeMessage",
	Categories = "categories",
	DisplayMessages = "displayMessages",
	Drinks = "drinks",
	OrderDrink = "order_drink",
	Orders = "orders",
	Users = "users",
}

// Alias types for improved usability
export type IsoDateString = string
export type RecordIdString = string
export type HTMLString = string

// System fields
export type BaseSystemFields<T = never> = {
	id: RecordIdString
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

export type AuthoriginsRecord = {
	collectionRef: string
	created?: IsoDateString
	fingerprint: string
	id: string
	recordRef: string
	updated?: IsoDateString
}

export type ExternalauthsRecord = {
	collectionRef: string
	created?: IsoDateString
	id: string
	provider: string
	providerId: string
	recordRef: string
	updated?: IsoDateString
}

export type MfasRecord = {
	collectionRef: string
	created?: IsoDateString
	id: string
	method: string
	recordRef: string
	updated?: IsoDateString
}

export type OtpsRecord = {
	collectionRef: string
	created?: IsoDateString
	id: string
	password: string
	recordRef: string
	sentTo?: string
	updated?: IsoDateString
}

export type SuperusersRecord = {
	created?: IsoDateString
	email: string
	emailVisibility?: boolean
	id: string
	password: string
	tokenKey: string
	updated?: IsoDateString
	verified?: boolean
}

export type ActiveMessageRecord = {
	created?: IsoDateString
	id: string
	isVisible?: boolean
	message?: RecordIdString
	updated?: IsoDateString
}

export type CategoriesRecord = {
	created?: IsoDateString
	id: string
	name: string
	sort_order: number
	updated?: IsoDateString
}

export type DisplayMessagesRecord = {
	created?: IsoDateString
	id: string
	subtext?: string
	title?: string
	updated?: IsoDateString
}

export type DrinksRecord = {
	category: RecordIdString
	created?: IsoDateString
	id: string
	image: string
	name: string
	price: number
	updated?: IsoDateString
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
	created?: IsoDateString
	drink: RecordIdString
	extras?: OrderDrinkExtrasOptions[]
	flavor?: OrderDrinkFlavorOptions[]
	id: string
	milk?: OrderDrinkMilkOptions
	serving_size?: OrderDrinkServingSizeOptions
	updated?: IsoDateString
}

export enum OrdersStateOptions {
	"received" = "received",
	"production" = "production",
	"completed" = "completed",
	"dispatched" = "dispatched",
}
export type OrdersRecord = {
	created?: IsoDateString
	customer?: RecordIdString
	drinks: RecordIdString[]
	id: string
	payment_fulfilled?: boolean
	state?: OrdersStateOptions
	updated?: IsoDateString
}

export type UsersRecord = {
	avatar?: string
	created?: IsoDateString
	email?: string
	emailVisibility?: boolean
	favorites?: RecordIdString[]
	id: string
	is_admin?: boolean
	name?: string
	password: string
	purchased_cup?: boolean
	tokenKey: string
	updated?: IsoDateString
	username: string
	verified?: boolean
}

// Response types include system fields and match responses from the PocketBase API
export type AuthoriginsResponse<Texpand = unknown> = Required<AuthoriginsRecord> & BaseSystemFields<Texpand>
export type ExternalauthsResponse<Texpand = unknown> = Required<ExternalauthsRecord> & BaseSystemFields<Texpand>
export type MfasResponse<Texpand = unknown> = Required<MfasRecord> & BaseSystemFields<Texpand>
export type OtpsResponse<Texpand = unknown> = Required<OtpsRecord> & BaseSystemFields<Texpand>
export type SuperusersResponse<Texpand = unknown> = Required<SuperusersRecord> & AuthSystemFields<Texpand>
export type ActiveMessageResponse<Texpand = unknown> = Required<ActiveMessageRecord> & BaseSystemFields<Texpand>
export type CategoriesResponse<Texpand = unknown> = Required<CategoriesRecord> & BaseSystemFields<Texpand>
export type DisplayMessagesResponse<Texpand = unknown> = Required<DisplayMessagesRecord> & BaseSystemFields<Texpand>
export type DrinksResponse<Texpand = unknown> = Required<DrinksRecord> & BaseSystemFields<Texpand>
export type OrderDrinkResponse<Texpand = unknown> = Required<OrderDrinkRecord> & BaseSystemFields<Texpand>
export type OrdersResponse<Texpand = unknown> = Required<OrdersRecord> & BaseSystemFields<Texpand>
export type UsersResponse<Texpand = unknown> = Required<UsersRecord> & AuthSystemFields<Texpand>

// Types containing all Records and Responses, useful for creating typing helper functions

export type CollectionRecords = {
	_authOrigins: AuthoriginsRecord
	_externalAuths: ExternalauthsRecord
	_mfas: MfasRecord
	_otps: OtpsRecord
	_superusers: SuperusersRecord
	activeMessage: ActiveMessageRecord
	categories: CategoriesRecord
	displayMessages: DisplayMessagesRecord
	drinks: DrinksRecord
	order_drink: OrderDrinkRecord
	orders: OrdersRecord
	users: UsersRecord
}

export type CollectionResponses = {
	_authOrigins: AuthoriginsResponse
	_externalAuths: ExternalauthsResponse
	_mfas: MfasResponse
	_otps: OtpsResponse
	_superusers: SuperusersResponse
	activeMessage: ActiveMessageResponse
	categories: CategoriesResponse
	displayMessages: DisplayMessagesResponse
	drinks: DrinksResponse
	order_drink: OrderDrinkResponse
	orders: OrdersResponse
	users: UsersResponse
}

// Type for usage with type asserted PocketBase instance
// https://github.com/pocketbase/js-sdk#specify-typescript-definitions

export type TypedPocketBase = PocketBase & {
	collection(idOrName: '_authOrigins'): RecordService<AuthoriginsResponse>
	collection(idOrName: '_externalAuths'): RecordService<ExternalauthsResponse>
	collection(idOrName: '_mfas'): RecordService<MfasResponse>
	collection(idOrName: '_otps'): RecordService<OtpsResponse>
	collection(idOrName: '_superusers'): RecordService<SuperusersResponse>
	collection(idOrName: 'activeMessage'): RecordService<ActiveMessageResponse>
	collection(idOrName: 'categories'): RecordService<CategoriesResponse>
	collection(idOrName: 'displayMessages'): RecordService<DisplayMessagesResponse>
	collection(idOrName: 'drinks'): RecordService<DrinksResponse>
	collection(idOrName: 'order_drink'): RecordService<OrderDrinkResponse>
	collection(idOrName: 'orders'): RecordService<OrdersResponse>
	collection(idOrName: 'users'): RecordService<UsersResponse>
}
