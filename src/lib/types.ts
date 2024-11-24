type State = "received" | "production" | "completed" | "dispatched";

class OrderDrink {
  name: string;

  constructor(data: { name: string }) {
    this.name = data.name;
  }
}

class Order {
  id: string;
  state: State;
  drinks: Array<OrderDrink>;

  constructor(data: { id: string; state: State; drinks: Array<OrderDrink> }) {
    this.id = data.id;
    this.state = data.state;
    this.drinks = data.drinks;
  }
}

export { OrderDrink, Order };
export type { State };

class Message {
  id: string;
  title: string;
  subtext: string;

  constructor(data: { id: string; title: string; subtext: string }) {
    this.id = data.id;
    this.title = data.title;
    this.subtext = data.subtext;
  }
}

class ActiveMessage {
  id: string;
  message: Message;
  visible: boolean;

  constructor(data: { id: string; message: Message; visible: boolean }) {
    this.id = data.id;
    this.message = data.message;
    this.visible = data.visible;
  }
}

export { Message, ActiveMessage };

class Item {
  id: string;
  name: string;
  price: number;
  category: string;
  image: string;

  constructor(data: { id: string; name: string; price: number; category: string; image: string }) {
    this.id = data.id;
    this.name = data.name;
    this.price = data.price;
    this.category = data.category;
    this.image = data.image;
  }
}

class Category {
  id: string;
  name: string;
  sortOrder: number;
  items: Item[];

  constructor(data: { id: string; name: string; sortOrder: number; items: Item[] }) {
    this.id = data.id;
    this.name = data.name;
    this.sortOrder = data.sortOrder;
    this.items = data.items;
  }
}

export { Item, Category };
