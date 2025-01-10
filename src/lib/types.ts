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

export class Record {
  id: RecordIdString;

  constructor(data: Record) {
    this.id = data.id;
  }
}

export class User extends Record {
  name: string;
  isAdmin: boolean;

  constructor(data: User) {
    super(data);
    this.name = data.name;
    this.isAdmin = data.isAdmin;
  }

  static fromPb(data: AuthModel): User {
    return new User({
      id: data?.id,
      name: data?.name,
      isAdmin: data?.is_admin
    });
  }
}

// orders
export type ExpandedOrderRecord = OrderResponse & {
  expand: { items: ExpandedOrderItemRecord[] };
};

export class Order extends Record implements RecordBase {
  state: State;
  items: Array<OrderItem>;

  constructor(data: Order) {
    super(data);
    this.state = data.state;
    this.items = data.items;
  }

  // FIXME: implement correctly
  toPb() {
    return this;
  }

  static fromPb(data: ExpandedOrderRecord): Order {
    return new Order({
      id: data.id,
      state: data.state,
      items: data.expand.items.map(OrderItem.fromPb)
    } as Order);
  }
}

export type ExpandedOrderItemRecord = OrderItemResponse & {
  expand: { item: ItemResponse };
};

export class OrderItem extends Record implements RecordBase {
  name: string;
  item: Item;

  constructor(data: OrderItem) {
    super(data);
    this.name = data.name;
    this.item = data.item;
  }

  toPb() {
    return this;
  }

  static fromPb(data: ExpandedOrderItemRecord): OrderItem {
    return new OrderItem({
      id: data.id,
      name: data.expand.item.name,
      item: Item.fromPb(data.expand.item)
    } as OrderItem);
  }
}

export class Item extends Record implements RecordBase {
  name: string;
  price: number;
  category: string;
  image: string;

  constructor(data: Item) {
    super(data);
    this.name = data.name;
    this.price = data.price;
    this.category = data.category;
    this.image = data.image;
  }

  toPb() {
    return this;
  }

  static fromPb(data: ItemResponse): Item {
    return new Item({
      id: data.id,
      name: data.name,
      price: data.price_nok,
      category: data.category,
      image: pb.files.getUrl(data, data.image)
    } as Item);
  }
}

export type ExpandedCategoryRecord = CategoryResponse & {
  expand: { item_via_category: ItemResponse[] };
};

export class Category extends Record implements RecordBase {
  name: string;
  sortOrder: number;
  items: Item[];

  constructor(data: Category) {
    super(data);
    this.name = data.name;
    this.sortOrder = data.sortOrder;
    this.items = data.items;
  }

  toPb() {
    return { name: this.name, sort_order: this.sortOrder };
  }

  static fromPb(data: ExpandedCategoryRecord): Category {
    return new Category({
      id: data.id,
      name: data.name,
      sortOrder: data.sort_order,
      items: data.expand.item_via_category.map(Item.fromPb)
    } as Category);
  }
}

// messages
export class Message extends Record implements RecordBase {
  title: string;
  subtitle: string;

  constructor(data: Message) {
    super(data);
    this.title = data.title;
    this.subtitle = data.subtitle;
  }

  toPb() {
    return { title: this.title, subtitle: this.subtitle };
  }

  static fromPb(data: MessageResponse): Message {
    return new Message({
      id: data.id,
      title: data.title,
      subtitle: data.subtitle
    } as Message);
  }
}

export type ExpandedActiveMessageRecord = StatusResponse & {
  expand: { message: MessageResponse };
};

export class ActiveMessage extends Record implements RecordBase {
  message: Message;
  visible: boolean;

  constructor(data: ActiveMessage) {
    super(data);
    this.message = data.message;
    this.visible = data.visible;
  }

  toPb() {
    return { message: this.message.id, online: this.visible };
  }

  static fromPb(data: ExpandedActiveMessageRecord): ActiveMessage {
    return new ActiveMessage({
      id: data.id,
      message:
        data.expand !== undefined
          ? Message.fromPb(data.expand.message)
          : new Message({
              id: "",
              title: "",
              subtitle: ""
            } as Message),
      visible: data.online ?? false
    } as ActiveMessage);
  }
}
