import pb, { type RecordIdString, OrdersStateOptions, type DrinksResponse } from "$lib/pocketbase";
import { restrictedRoutes, adminRoutes } from "$lib/constants";

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

  constructor(data: { id: RecordIdString }) {
    this.id = data.id;
  }
}

// orders
export class Order extends Record {
  state: State;
  items: Array<OrderItem>;

  constructor(data: { id: RecordIdString; state: State; drinks: Array<OrderItem> }) {
    super(data);
    this.state = data.state;
    this.items = data.drinks;
  }

  static fromPb(data: {
    id: RecordIdString;
    state: State;
    expand: { drinks: { id: RecordIdString; expand: { drink: DrinksResponse } }[] };
  }): Order {
    return new Order({
      id: data.id,
      state: data.state,
      drinks: data.expand.drinks.map(OrderItem.fromPb)
    });
  }
}

export class OrderItem extends Record {
  name: string;
  item: Item;

  constructor(data: { id: RecordIdString; name: string; item: Item }) {
    super(data);
    this.name = data.name;
    this.item = data.item;
  }

  static fromPb(data: { id: RecordIdString; expand: { drink: DrinksResponse } }): OrderItem {
    return new OrderItem({
      ...data,
      name: data.expand.drink.name,
      item: Item.fromPb(data.expand.drink)
    });
  }
}

export class Item extends Record {
  name: string;
  price: number;
  category: string;
  image: string;

  constructor(data: {
    id: RecordIdString;
    name: string;
    price: number;
    category: string;
    image: string;
  }) {
    super(data);
    this.name = data.name;
    this.price = data.price;
    this.category = data.category;
    this.image = data.image;
  }

  static fromPb(data: {
    id: RecordIdString;
    name: string;
    price: number;
    category: string;
    image: string;
  }): Item {
    return new Item({
      ...data,
      image: pb.files.getURL(data, data.image)
    });
  }
}

export class Category extends Record {
  name: string;
  sortOrder: number;
  items: Item[];

  constructor(data: { id: RecordIdString; name: string; sortOrder: number; items: Item[] }) {
    super(data);
    this.name = data.name;
    this.sortOrder = data.sortOrder;
    this.items = data.items;
  }

  static fromPb(data: {
    id: RecordIdString;
    name: string;
    sort_order: number;
    expand: { drinks_via_category: DrinksResponse[] };
  }): Category {
    return new Category({
      ...data,
      sortOrder: data.sort_order,
      items: data.expand.drinks_via_category.map(Item.fromPb)
    });
  }
}

// messages
export class Message extends Record {
  title: string;
  subtext: string;

  constructor(data: { id: RecordIdString; title: string; subtext: string }) {
    super(data);
    this.title = data.title;
    this.subtext = data.subtext;
  }

  static fromPb(data: { id: RecordIdString; title: string; subtext: string }): Message {
    return new Message(data);
  }
}

export class ActiveMessage extends Record {
  message: Message;
  visible: boolean;

  constructor(data: { id: RecordIdString; message: Message; visible: boolean }) {
    super(data);
    this.message = data.message;
    this.visible = data.visible;
  }

  static fromPb(data: {
    id: RecordIdString;
    expand: { message: Message };
    isVisible: boolean;
  }): ActiveMessage {
    return new ActiveMessage({
      id: data.id,
      message:
        data.expand !== undefined
          ? Message.fromPb(data.expand.message)
          : new Message({
              id: "",
              title: "",
              subtext: ""
            }),
      visible: data.isVisible
    });
  }
}
