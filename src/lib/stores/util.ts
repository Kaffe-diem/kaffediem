import { categories, items, customizationKeys, customizationValues } from "$stores/menuStore";

import { raw_orders, userOrders } from "$stores/orderStore";
import orders from "$stores/orderStore";
import { status } from "$stores/statusStore";

export function resetStores() {
  categories.reset();
  items.reset();
  customizationKeys.reset();
  customizationValues.reset();
  raw_orders.reset();
  userOrders.reset();
  orders.reset();
  status.reset();
}
