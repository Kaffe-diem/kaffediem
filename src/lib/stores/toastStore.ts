import { writable } from "svelte/store";

export type ToastType = "info" | "success" | "error" | "warning";

export interface Toast {
  id: string;
  message: string;
  type: ToastType;
  timeout: number;
}

function createToastStore() {
  const { subscribe, update } = writable<Toast[]>([]);

  function addToast(message: string, type: ToastType = "info", timeout: number = 7_000) {
    const id = Math.random().toString(36).substring(2, 9);

    update((toasts) => {
      const newToast = { id, message, type, timeout };

      const updatedToasts = [...toasts, newToast];

      setTimeout(() => {
        removeToast(id);
      }, timeout);

      return updatedToasts;
    });
  }

  function removeToast(id: string) {
    update((toasts) => toasts.filter((toast) => toast.id !== id));
  }

  return {
    subscribe,
    add: addToast,
    remove: removeToast,
    info: (message: string, timeout?: number) => addToast(message, "info", timeout),
    success: (message: string, timeout?: number) => addToast(message, "success", timeout),
    error: (message: string, timeout?: number) => addToast(message, "error", timeout),
    warning: (message: string, timeout?: number) => addToast(message, "warning", timeout)
  };
}

export const toasts = createToastStore();
