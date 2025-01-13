import pb, {
  type RecordIdString,
  OrderStateOptions,
  type ItemResponse,
  type MessageResponse,
  type OrderResponse,
  type OrderItemResponse,
  type CategoryResponse,
  type StatusResponse
} from "$lib/pocketbase";
import { restrictedRoutes, adminRoutes } from "$lib/constants";
import type { AuthModel } from "pocketbase";

export class NavItem {
  href: string;
  text: string;
  requiresAuth: boolean;
  requiresAdmin: boolean;

  constructor(href: string, text: string) {
    this.href = href;
    this.text = text;
    this.requiresAuth = restrictedRoutes.includes(href);
    this.requiresAdmin = adminRoutes.includes(href);
  }
}

type State = OrderStateOptions;
export { OrderStateOptions as State };

export interface RecordBase {
  id: RecordIdString;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  toPb(): any;
  // fromPb(data: any): RecordClass; // can't have static methods in interface https://github.com/microsoft/TypeScript/issues/13462
}

export class User {
  constructor(
    public readonly id: RecordIdString,
    public readonly name: string,
    public readonly isAdmin: boolean
  ) {}

  static fromPb(data: AuthModel): User {
    return new User(data?.id, data?.name, data?.is_admin);
  }
}

// orders
export type ExpandedOrderRecord = OrderResponse & {
  expand: { items: ExpandedOrderItemRecord[] };
};

export class Order implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly state: State,
    public readonly items: Array<OrderItem>
  ) {}

  // FIXME: implement correctly
  toPb() {
    return this;
  }

  static fromPb(data: ExpandedOrderRecord): Order {
    return new Order(data.id, data.state, data.expand.items.map(OrderItem.fromPb));
  }
}

export type ExpandedOrderItemRecord = OrderItemResponse & {
  expand: { item: ItemResponse };
};

export class OrderItem implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly name: string,
    public readonly item: Item
  ) {}

  toPb() {
    return this;
  }

  static fromPb(data: ExpandedOrderItemRecord): OrderItem {
    return new OrderItem(data.id, data.expand.item.name, Item.fromPb(data.expand.item));
  }
}

export class Item implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly name: string,
    public readonly price: number,
    public readonly category: string,
    public readonly image: string
  ) {}

  toPb() {
    return this;
  }

  static fromPb(data: ItemResponse): Item {
    return new Item(
      data.id,
      data.name,
      data.price_nok,
      data.category,
      pb.files.getUrl(data, data.image)
    );
  }
}

export type ExpandedCategoryRecord = CategoryResponse & {
  expand: { item_via_category: ItemResponse[] };
};

export class Category implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly name: string,
    public readonly sortOrder: number,
    public readonly items: Item[]
  ) {}

  toPb() {
    return { name: this.name, sort_order: this.sortOrder };
  }

  static fromPb(data: ExpandedCategoryRecord): Category {
    return new Category(
      data.id,
      data.name,
      data.sort_order,
      data.expand.item_via_category.map(Item.fromPb)
    );
  }
}

// messages
export class Message implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly title: string,
    public readonly subtitle: string
  ) {}

  static baseValue = { id: "", title: "", subtitle: "" } as Message;

  toPb() {
    return { title: this.title, subtitle: this.subtitle };
  }

  static fromPb(data: MessageResponse): Message {
    return new Message(data.id, data.title, data.subtitle);
  }
}

export class Status implements RecordBase {
  constructor(
    public readonly id: RecordIdString,
    public readonly message: Message,
    public readonly messages: Message[],
    public readonly online: boolean
  ) {}

  static baseValue = {
    id: "",
    online: false,
    message: Message.baseValue,
    messages: [Message.baseValue]
  } as Status;

  toPb() {
    return { message: this.message.id, online: this.online };
  }

  static fromPb(status: StatusResponse, messages: Message[]): Status {
    return new Status(
      status.id,
      messages.filter((m) => m.id == status.message)[0] || Message.baseValue,
      messages,
      status.online
    );
  }
}
