type State = "received" | "production" | "completed" | "dispatched";

class Order {
  id: string;
  state: State;
  collectionId: string;
  collectionName: string;
  created: Date;
  customer: string;
  drinks: Array<any>;
  paymentFulfilled: boolean;
  updated: Date;

  constructor(data: {
    id: string;
    state: string;
    collectionId: string;
    collectionName: string;
    created: string;
    customer: string;
    drinks: Array<any>;
    payment_fulfilled: boolean;
    updated: string;
  }) {
    this.id = data.id;
    this.state = data.state;
    this.collectionId = data.collectionId;
    this.collectionName = data.collectionName;
    this.created = new Date(data.created);
    this.customer = data.customer;
    this.drinks = data.drinks;
    this.paymentFulfilled = data.payment_fulfilled;
    this.updated = new Date(data.updated);
  }
}

export { Order };
export type { State };
