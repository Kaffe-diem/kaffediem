import {
  categories,
  items,
  customizationKeys,
  customizationValues,
  itemCustomizations
} from "$stores/menu";

import { orders } from "$stores/orders";
import { status, messages } from "$stores/status";

export function resetStores() {
  // New stores don't need reset() - they auto-sync via websocket
}
