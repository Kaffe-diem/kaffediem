import pocketbase from "pocketbase";
import * as pbt from "./pb.d";

export const pb = new pocketbase(process.env.PUBLIC_PB_HOST) as pbt.TypedPocketBase;
await pb.admins.authWithPassword(
  process.env.PUBLIC_PB_ADMIN_EMAIL!,
  process.env.PUBLIC_PB_ADMIN_PASSWORD!
);

export const OrderService = {
  createOrder: async () => {
    const orderDrinkIds = [
        (await OrderService._createOrderDrink()).id
    ];

    console.log(orderDrinkIds)
    return pb.collection("orders").create({
      drinks: orderDrinkIds,
      // admin does not work, as its not stored in users collection.
      // so this is hardcoded to a random user. todo.
      customer: 'yl4tj93hwcsziys',
      order_fulfilled: false,
      payment_fulfilled: false
    });
  },

  _createOrderDrink: async () => {
    return pb.collection("order_drink").create({
        drink: "w72i4rxynu94w35",
        milk: pbt.OrderDrinkMilkOptions.whole,
        serving_size: pbt.OrderDrinkServingSizeOptions.big,
        extras: [pbt.OrderDrinkExtrasOptions.cream],
        flavor: [pbt.OrderDrinkFlavorOptions.irish]
    });
  }
}