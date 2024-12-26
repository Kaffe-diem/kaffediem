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

  static fromPb(data: ExpandedOrderRecord) {
    return new Order({
      id: data.id,
      state: data.state,
      items: data.expand.drinks.map(OrderItem.fromPb)
    });
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

  static fromPb(data: ExpandedOrderDrinkRecord) {
    return new OrderItem({
      id: data.id,
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

  constructor(data: Item) {
    super(data);
    this.name = data.name;
    this.price = data.price;
    this.category = data.category;
    this.image = data.image;
  }

  static fromPb(data: DrinksResponse) {
    return new Item({
      id: data.id,
      name: data.name,
      price: data.price,
      category: data.category,
      image: pb.files.getUrl(data, data.image)
    });
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

  static fromPb(data: ExpandedCategoryRecord) {
    return new Category({
      id: data.id,
      name: data.name,
      sortOrder: data.sort_order,
      items: data.expand.drinks_via_category.map(Item.fromPb)
    });
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

  static fromPb(data: Message) {
    return new Message(data);
  }
}

type ExpandedActiveMessageRecord = ActiveMessageResponse & {
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

  static fromPb(data: ExpandedActiveMessageRecord) {
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
