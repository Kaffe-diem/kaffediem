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
	Category = "category",
	CustomizationKey = "customization_key",
	CustomizationValue = "customization_value",
	Item = "item",
	ItemCustomization = "item_customization",
	Message = "message",
	Order = "order",
	OrderItem = "order_item",
	Status = "status",
	User = "user",
}

// Alias types for improved usability
export type IsoDateString = string
export type RecordIdString = string
export type HTMLString = string

type ExpandType<T> = unknown extends T
	? T extends unknown
		? { expand?: unknown }
		: { expand: T }
	: { expand: T }

// System fields
export type BaseSystemFields<T = unknown> = {
	id: RecordIdString
	collectionId: string
	collectionName: Collections
} & ExpandType<T>

export type AuthSystemFields<T = unknown> = {
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

export type CategoryRecord = {
	created?: IsoDateString
	enable?: boolean
	id: string
	name: string
	sort_order: number
	updated?: IsoDateString
	valid_customization_keys?: RecordIdString[]
}

export type CustomizationKeyRecord = {
	created?: IsoDateString
	default_value?: RecordIdString
	enable?: boolean
	id: string
	label_color: string
	multiple_choice?: boolean
	name: string
	updated?: IsoDateString
}

export type CustomizationValueRecord = {
	belongs_to: RecordIdString
	constant_price?: boolean
	created?: IsoDateString
	enable?: boolean
	id: string
	name: string
	price_increment_nok?: number
	updated?: IsoDateString
}

export type ItemRecord = {
	category: RecordIdString
	created?: IsoDateString
	enable?: boolean
	id: string
	image?: string
	name: string
	price_nok: number
	updated?: IsoDateString
}

export type ItemCustomizationRecord = {
	created?: IsoDateString
	id: string
	key: RecordIdString
	updated?: IsoDateString
	value: RecordIdString[]
}

export type MessageRecord = {
	created?: IsoDateString
	id: string
	subtitle?: string
	title?: string
	updated?: IsoDateString
}

export enum OrderStateOptions {
	"received" = "received",
	"production" = "production",
	"completed" = "completed",
	"dispatched" = "dispatched",
}
export type OrderRecord = {
	created?: IsoDateString
	customer?: RecordIdString
	day_id?: number
	id: string
	items: RecordIdString[]
	missing_information?: boolean
	state: OrderStateOptions
	updated?: IsoDateString
}

export type OrderItemRecord = {
	created?: IsoDateString
	customization?: RecordIdString[]
	id: string
	item: RecordIdString
	updated?: IsoDateString
}

export type StatusRecord = {
	created?: IsoDateString
	id: string
	message?: RecordIdString
	online?: boolean
	updated?: IsoDateString
}

export type UserRecord = {
	avatar?: string
	created?: IsoDateString
	email?: string
	emailVisibility?: boolean
	id: string
	is_admin?: boolean
	name?: string
	password: string
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
export type CategoryResponse<Texpand = unknown> = Required<CategoryRecord> & BaseSystemFields<Texpand>
export type CustomizationKeyResponse<Texpand = unknown> = Required<CustomizationKeyRecord> & BaseSystemFields<Texpand>
export type CustomizationValueResponse<Texpand = unknown> = Required<CustomizationValueRecord> & BaseSystemFields<Texpand>
export type ItemResponse<Texpand = unknown> = Required<ItemRecord> & BaseSystemFields<Texpand>
export type ItemCustomizationResponse<Texpand = unknown> = Required<ItemCustomizationRecord> & BaseSystemFields<Texpand>
export type MessageResponse<Texpand = unknown> = Required<MessageRecord> & BaseSystemFields<Texpand>
export type OrderResponse<Texpand = unknown> = Required<OrderRecord> & BaseSystemFields<Texpand>
export type OrderItemResponse<Texpand = unknown> = Required<OrderItemRecord> & BaseSystemFields<Texpand>
export type StatusResponse<Texpand = unknown> = Required<StatusRecord> & BaseSystemFields<Texpand>
export type UserResponse<Texpand = unknown> = Required<UserRecord> & AuthSystemFields<Texpand>

// Types containing all Records and Responses, useful for creating typing helper functions

export type CollectionRecords = {
	_authOrigins: AuthoriginsRecord
	_externalAuths: ExternalauthsRecord
	_mfas: MfasRecord
	_otps: OtpsRecord
	_superusers: SuperusersRecord
	category: CategoryRecord
	customization_key: CustomizationKeyRecord
	customization_value: CustomizationValueRecord
	item: ItemRecord
	item_customization: ItemCustomizationRecord
	message: MessageRecord
	order: OrderRecord
	order_item: OrderItemRecord
	status: StatusRecord
	user: UserRecord
}

export type CollectionResponses = {
	_authOrigins: AuthoriginsResponse
	_externalAuths: ExternalauthsResponse
	_mfas: MfasResponse
	_otps: OtpsResponse
	_superusers: SuperusersResponse
	category: CategoryResponse
	customization_key: CustomizationKeyResponse
	customization_value: CustomizationValueResponse
	item: ItemResponse
	item_customization: ItemCustomizationResponse
	message: MessageResponse
	order: OrderResponse
	order_item: OrderItemResponse
	status: StatusResponse
	user: UserResponse
}

// Type for usage with type asserted PocketBase instance
// https://github.com/pocketbase/js-sdk#specify-typescript-definitions

export type TypedPocketBase = PocketBase & {
	collection(idOrName: '_authOrigins'): RecordService<AuthoriginsResponse>
	collection(idOrName: '_externalAuths'): RecordService<ExternalauthsResponse>
	collection(idOrName: '_mfas'): RecordService<MfasResponse>
	collection(idOrName: '_otps'): RecordService<OtpsResponse>
	collection(idOrName: '_superusers'): RecordService<SuperusersResponse>
	collection(idOrName: 'category'): RecordService<CategoryResponse>
	collection(idOrName: 'customization_key'): RecordService<CustomizationKeyResponse>
	collection(idOrName: 'customization_value'): RecordService<CustomizationValueResponse>
	collection(idOrName: 'item'): RecordService<ItemResponse>
	collection(idOrName: 'item_customization'): RecordService<ItemCustomizationResponse>
	collection(idOrName: 'message'): RecordService<MessageResponse>
	collection(idOrName: 'order'): RecordService<OrderResponse>
	collection(idOrName: 'order_item'): RecordService<OrderItemResponse>
	collection(idOrName: 'status'): RecordService<StatusResponse>
	collection(idOrName: 'user'): RecordService<UserResponse>
}
