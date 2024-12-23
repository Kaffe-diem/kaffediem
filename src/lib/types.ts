import { type RecordIdString, OrdersStateOptions } from "$lib/pocketbase";
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
}

export class OrderItem extends Record {
  name: string;
  item: Item;

  constructor(data: { id: RecordIdString; name: string; item: Item }) {
    super(data);
    this.name = data.name;
    this.item = data.item;
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
}

export class ActiveMessage extends Record {
  message: Message;
  visible: boolean;

  constructor(data: { id: RecordIdString; message: Message; visible: boolean }) {
    super(data);
    this.message = data.message;
    this.visible = data.visible;
  }
}
