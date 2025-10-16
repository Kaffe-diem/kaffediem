import {
  OrderStateOptions,
  type RecordIdString,
  type CategoryDTO,
  type CustomizationKeyDTO,
  type CustomizationValueDTO,
  type ItemCustomizationDTO,
  type ItemDTO,
  type MessageDTO,
  type OrderDTO,
  type OrderItemSnapshotDTO,
  type StatusDTO
} from "$lib/api/contracts";
import { restrictedRoutes, adminRoutes } from "$lib/constants";

type BackendUserRecord = {
  id?: RecordIdString;
  name?: string;
  is_admin?: boolean;
};

type NavItems = "/account" | "/admin";

export class NavItem {
  href: NavItems;
  text: string;
  requiresAuth: boolean;
  requiresAdmin: boolean;

  constructor(href: NavItems, text: string) {
    this.href = href;
    this.text = text;
    this.requiresAuth = restrictedRoutes.includes(href);
    this.requiresAdmin = adminRoutes.includes(href);
  }
}

type State = OrderStateOptions;
export { OrderStateOptions as State };
export { OrderStateOptions, Collections } from "$lib/api/contracts";
export type { RecordIdString } from "$lib/api/contracts";

export interface RecordBase {
  id: RecordIdString;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  toApi(): any;
}

export class User {
  constructor(
    public readonly id: RecordIdString,
    public readonly name: string,
    public readonly isAdmin: boolean
  ) {}

  static fromBackend(data: BackendUserRecord | null): User {
    if (!data) {
      return new User("", "", false);
    }
    return new User(data?.id ?? "", data?.name ?? "", data?.is_admin ?? false);
  }
}

export class OrderItemSnapshot {
  constructor(
    public readonly itemId: RecordIdString,
    public readonly name: string,
    public readonly price: number,
    public readonly category: RecordIdString,
    public readonly customizations: Array<{
      keyId: RecordIdString;
      keyName: string;
      valueId: RecordIdString;
      valueName: string;
      priceChange: number;
    }>
  ) {}

  static fromApi(data: OrderItemSnapshotDTO): OrderItemSnapshot {
    return new OrderItemSnapshot(
      data.item_id,
      data.name,
      parseFloat(data.price),
      data.category,
      data.customizations.map((c) => ({
        keyId: c.key_id,
        keyName: c.key_name,
        valueId: c.value_id,
        valueName: c.value_name,
        priceChange: parseFloat(c.price_change)
      }))
    );
  }
}

export class Order implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly state: State,
    public readonly items: Array<OrderItemSnapshot>,
    public readonly missingInformation: boolean,
    public readonly dayId: number,
    public readonly customerId: number | null,
    public readonly createdAt?: string,
    public readonly updatedAt?: string
  ) {}

  toApi() {
    return {
      state: this.state,
      missing_information: this.missingInformation
    };
  }

  static fromApi(data: OrderDTO): Order {
    const items = data.items?.map(OrderItemSnapshot.fromApi) ?? [];
    return new Order(
      data.id,
      data.state,
      items,
      data.missing_information,
      data.day_id,
      data.customer_id ?? null,
      data.created,
      data.updated
    );
  }
}

export class Item implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly name: string,
    public readonly price: number,
    public readonly category: string,
    public readonly imageName: string, // pb field value
    public readonly image: string, // url to actual image
    public readonly enabled: boolean,
    public readonly sortOrder: number,
    public readonly imageFile: File | null = null // file with uploaded image contents
  ) {}

  toApi() {
    // Looks like FormData is necessary when dealing with files.
    const formData = new FormData();
    formData.append("name", this.name);
    formData.append("price_nok", this.price.toString());
    formData.append("category", this.category);
    formData.append("enable", this.enabled.toString()); // FormData expects string
    formData.append("sort_order", this.sortOrder.toString());
    if (this.imageFile) {
      formData.append("image", this.imageFile);
    } else {
      formData.append("image", this.imageName);
    }
    return formData;
  }

  static fromApi(data: ItemDTO): Item {
    return new Item(
      data.id,
      data.name,
      data.price_nok,
      data.category,
      data.image ?? "",
      resolveFileUrl(data.image),
      data.enable,
      data.sort_order
    );
  }

  static empty(): Item {
    return new Item("", "", 0, "", "", "", false, 0);
  }
}

export class Category implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly name: string,
    public readonly sortOrder: number,
    public readonly enabled: boolean,
    public readonly validCustomizations: string[]
  ) {}

  toApi() {
    return {
      name: this.name,
      sort_order: this.sortOrder,
      enable: this.enabled,
      valid_customizations: this.validCustomizations
    };
  }

  static fromApi(data: CategoryDTO): Category {
    return new Category(
      data.id,
      data.name,
      data.sort_order,
      data.enable,
      data.valid_customizations
    );
  }
}

const resolveFileUrl = (fileName?: string | null) => {
  if (!fileName) return "";
  if (fileName.startsWith("http")) return fileName;
  return fileName;
};

export class Message implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly title: string,
    public readonly subtitle: string
  ) {}

  static baseValue = new Message("", "", "");

  toApi() {
    return { title: this.title, subtitle: this.subtitle };
  }

  static fromApi(data: MessageDTO): Message {
    return new Message(data.id, data.title ?? "", data.subtitle ?? "");
  }
}

export class Status implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly message: Message,
    public readonly messages: Message[],
    public readonly open: boolean,
    public readonly showMessage: boolean
  ) {}

  static baseValue = new Status("", Message.baseValue, [Message.baseValue], false, false);

  toApi() {
    return { message_id: this.message.id, open: this.open, show_message: this.showMessage };
  }

  static fromApi(status: StatusDTO, messages: Message[]): Status {
    const inlineMessage = status.message ? Message.fromApi(status.message) : null;
    const lookupId = status.message_id ?? inlineMessage?.id ?? "";
    const resolved = messages.find((m) => m.id === lookupId) ?? inlineMessage ?? Message.baseValue;

    const mergedMessages =
      inlineMessage && !messages.find((m) => m.id === inlineMessage.id)
        ? [...messages, inlineMessage]
        : messages;

    return new Status(status.id, resolved, mergedMessages, status.open, status.show_message);
  }
}

export class CustomizationKey implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly name: string,
    public readonly enabled: boolean,
    public readonly labelColor: string,
    public readonly defaultValue: string,
    public readonly multipleChoice: boolean,
    public readonly sortOrder: number
  ) {}

  toApi() {
    return {
      name: this.name,
      enable: this.enabled,
      label_color: this.labelColor,
      default_value: this.defaultValue,
      multiple_choice: this.multipleChoice,
      sort_order: this.sortOrder
    };
  }

  static fromApi(data: CustomizationKeyDTO): CustomizationKey {
    return new CustomizationKey(
      data.id,
      data.name || "",
      data.enable,
      data.label_color ?? "",
      data.default_value ?? "",
      data.multiple_choice,
      data.sort_order
    );
  }
}

export class CustomizationValue implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly name: string,
    public readonly priceChange: number,
    public readonly constantPrice: boolean,
    public readonly belongsTo: RecordIdString,
    public readonly enabled: boolean,
    public readonly sortOrder: number
  ) {}

  toApi() {
    return {
      name: this.name,
      // TODO: rename in db:
      price_increment_nok: this.priceChange,
      constant_price: this.constantPrice,
      belongs_to: this.belongsTo,
      enable: this.enabled,
      sort_order: this.sortOrder
    };
  }

  static fromApi(data: CustomizationValueDTO): CustomizationValue {
    return new CustomizationValue(
      data.id,
      data.name,
      data.price_increment_nok, // TODO: rename in db
      data.constant_price,
      data.belongs_to,
      data.enable,
      data.sort_order
    );
  }
}

export class ItemCustomization implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly keyId: RecordIdString,
    public readonly valueIds: RecordIdString[]
  ) {}

  toApi() {
    return {
      key_id: this.keyId,
      value_ids: this.valueIds
    };
  }

  static fromApi(data: ItemCustomizationDTO): ItemCustomization {
    return new ItemCustomization(data.id, data.key_id, data.value_ids ?? []);
  }
}
