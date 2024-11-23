type State = "received" | "production" | "completed" | "dispatched";

class Drink {
  name: string;

  constructor(data: { name: string }) {
    this.name = data.name;
  }
}

class Order {
  id: string;
  state: State;
  drinks: Array<Drink>;

  constructor(data: { id: string; state: State; drinks: Array<Drink> }) {
    this.id = data.id;
    this.state = data.state;
    this.drinks = data.drinks;
  }
}

export { Drink, Order };
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
