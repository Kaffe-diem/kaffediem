import { get } from "svelte/store";
import { createCollection, apiPost, apiPatch } from "./collection";
import { orderFromApi, type OrderState, type RecordIdString } from "$lib/types";
import { toasts } from "$stores/toastStore";

type CreateOrderPayload = {
  customer_id: number;
  items: {
    item: string;
    customizations: { key: string; value: string[] }[];
  }[];
  state: OrderState;
  missing_information: boolean;
};

// Get today's date for filtering
function getTodayISO(): string {
  return new Date().toISOString().split("T")[0] || "";
}

// The orders store - automatically syncs with backend
export const orders = createCollection("order", orderFromApi, {
  queryParams: {
    from_date: getTodayISO()
  },
  onCreate: (order) => {
    const orderNum = order.dayId || order.id;
    toasts.success(`${orderNum}`);
  }
});

// Undo history
const undoStack: { orderId: string; previousState: OrderState }[] = [];

// Order operations
export async function createOrder(
  customerId: RecordIdString | number,
  items: { id: string; customizations?: { id: string; belongsTo?: string }[] }[],
  missingInfo: boolean
): Promise<void> {
  const customerIdNumber =
    typeof customerId === "number" ? customerId : Number.parseInt(customerId, 10);

  if (Number.isNaN(customerIdNumber)) {
    throw new Error("Invalid customer id");
  }

  const payload: CreateOrderPayload = {
    customer_id: customerIdNumber,
    items: items.map((item) => ({
      item: item.id,
      customizations: (item.customizations ?? [])
        .filter((c) => c.belongsTo)
        .map((c) => ({
          key: c.belongsTo!,
          value: [c.id]
        }))
    })),
    state: "received",
    missing_information: missingInfo
  };

  await apiPost("order", payload);
}

export async function updateOrderState(orderId: string, newState: OrderState): Promise<void> {
  // Save for undo
  const order = get(orders).find((o) => o.id === orderId);
  if (order) {
    undoStack.push({
      orderId,
      previousState: order.state
    });
  }

  await apiPatch("order", orderId, { state: newState });
}

export async function setAllOrdersState(state: OrderState): Promise<void> {
  const allOrders = get(orders);
  await Promise.all(allOrders.map((order) => apiPatch("order", order.id, { state })));
}

export async function undoLastStateChange(): Promise<void> {
  const last = undoStack.pop();
  if (last) {
    await apiPatch("order", last.orderId, { state: last.previousState });
  }
}
