enum State {
  Received,
  Production,
  Complete
}

class Order {
  id: number;
  state: State;

  constructor(id: number, state = State.Received) {
    this.id = id;
    this.state = state;
  }
}

export { State, Order };
