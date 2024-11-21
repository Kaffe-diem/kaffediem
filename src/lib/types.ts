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
