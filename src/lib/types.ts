import pb, {
  type RecordIdString,
  OrdersStateOptions,
  type DrinksResponse,
  type ActiveMessageResponse,
  type OrdersResponse,
  type OrderDrinkResponse,
  type CategoriesResponse
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
type ExpandedOrderRecord = OrdersResponse & {
  expand: { drinks: ExpandedOrderDrinkRecord[] };
};

export class Order extends Record {
  state: State;
  items: Array<OrderItem>;

  constructor(data: Order) {
    super(data);
    this.state = data.state;
    this.items = data.items;
  }

  static fromPb(data: ExpandedOrderRecord): Order {
    return new Order({
      id: data.id,
      state: data.state,
      items: data.expand.drinks.map(OrderItem.fromPb)
    } as Order);
  }
}

type ExpandedOrderDrinkRecord = OrderDrinkResponse & {
  expand: { drink: DrinksResponse };
};

export class OrderItem extends Record {
  name: string;
  item: Item;

  constructor(data: OrderItem) {
    super(data);
    this.name = data.name;
    this.item = data.item;
  }

  static fromPb(data: ExpandedOrderDrinkRecord): OrderItem {
    return new OrderItem({
      id: data.id,
      name: data.expand.drink.name,
      item: Item.fromPb(data.expand.drink)
    } as OrderItem);
  }
}

export class Item extends Record {
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

type ExpandedCategoryRecord = CategoriesResponse & {
  expand: { drinks_via_category: DrinksResponse[] };
};

export class Category extends Record {
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
export class Message extends Record {
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

  static fromPb(data: Message): Message {
    return new Message(data);
  }
}

export type ExpandedActiveMessageRecord = ActiveMessageResponse & {
  expand: { message: Message };
};

export class ActiveMessage extends Record {
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

  static fromPb(data: ExpandedActiveMessageRecord): ActiveMessage {
    return new ActiveMessage({
      id: data.id,
      message:
        data.expand !== undefined
          ? Message.fromPb(data.expand.message)
          : new Message({
              id: "",
              title: "",
              subtext: ""
            } as Message),
      visible: data.isVisible
    } as ActiveMessage);
  }
}
