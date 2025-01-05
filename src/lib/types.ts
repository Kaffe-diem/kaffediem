import pb, {
  type RecordIdString,
  OrdersStateOptions,
  type DrinksResponse,
  type ActiveMessageResponse,
  type OrdersResponse,
  type OrderDrinkResponse,
  type CategoriesResponse,
  type DisplayMessagesResponse
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

type State = OrdersStateOptions;
export { OrdersStateOptions as State };

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
export type ExpandedOrderRecord = OrdersResponse & {
  expand: { drinks: ExpandedOrderDrinkRecord[] };
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
      items: data.expand.drinks.map(OrderItem.fromPb)
    } as Order);
  }
}

export type ExpandedOrderDrinkRecord = OrderDrinkResponse & {
  expand: { drink: DrinksResponse };
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

  static fromPb(data: ExpandedOrderDrinkRecord): OrderItem {
    return new OrderItem({
      id: data.id,
      name: data.expand.drink.name,
      item: Item.fromPb(data.expand.drink)
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

  static fromPb(data: DrinksResponse): Item {
    return new Item({
      id: data.id,
      name: data.name,
      price: data.price,
      category: data.category,
      image: pb.files.getUrl(data, data.image)
    } as Item);
  }
}

export type ExpandedCategoryRecord = CategoriesResponse & {
  expand: { drinks_via_category: DrinksResponse[] };
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
      items: data.expand.drinks_via_category.map(Item.fromPb)
    } as Category);
  }
}

// messages
export class Message extends Record implements RecordBase {
  title: string;
  subtext: string;

  constructor(data: Message) {
    super(data);
    this.title = data.title;
    this.subtext = data.subtext;
  }

  toPb() {
    return this;
  }

  static fromPb(data: DisplayMessagesResponse): Message {
    return new Message({
      id: data.id,
      title: data.title,
      subtext: data.subtext
    } as Message);
  }
}

export class ActiveMessage extends Record implements RecordBase {
  message: Message;
  visible: boolean;

  constructor(data: ActiveMessage) {
    super(data);
    this.message = data.message;
    this.visible = data.visible;
  }

  toPb() {
    return { message: this.message.id, isVisible: this.visible };
  }

  static fromPb(
    activeMessage: ActiveMessageResponse,
    message: DisplayMessagesResponse
  ): ActiveMessage {
    return new ActiveMessage({
      id: activeMessage.id,
      message: Message.fromPb(message),
      visible: activeMessage.isVisible
    } as ActiveMessage);
  }
}
