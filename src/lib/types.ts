enum State {
	Production,
	Complete
}

class Order {
	id: number;
	state: State;

	constructor(id: number, state = State.Production) {
		this.id = id;
		this.state = state;
	}
}

export { State, Order };
