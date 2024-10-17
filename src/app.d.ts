// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces

import PocketBase from "pocketbase";

declare global {
  namespace App {
    // interface Error {}
    interface Locals {
      pb: PocketBase;
      id: string;
      email: string;
    }
    // interface PageData {}
    // interface PageState {}
    // interface Platform {}
  }
}

export {};
