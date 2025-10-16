<script lang="ts">
  import { setAllOrdersState } from "$stores/orders";
  import { State } from "$lib/types";
  import { resolve } from "$app/paths";

  type AdminPages =
    | "/admin/orders/frontdesk"
    | "/admin/orders/kitchen"
    | "/display"
    | "/admin/message"
    | "/admin/menu"
    | "/admin/stats";

  class AdminPage {
    href: AdminPages;
    text: string;

    constructor(href: AdminPages, text: string) {
      this.href = href;
      this.text = text;
    }
  }

  const adminPages = [
    new AdminPage("/admin/orders/frontdesk", "Bestillingsdisk"),
    new AdminPage("/admin/orders/kitchen", "Kjøkken"),
    new AdminPage("/display", "Visning"),
    new AdminPage("/admin/message", "Rediger skjermmelding"),
    new AdminPage("/admin/menu", "Rediger meny"),
    new AdminPage("/admin/stats", "Dagens bestillinger")
  ];
</script>

<ul>
  <li>
    <button
      class="btn btn-error relative m-4 flex h-24 w-full flex-col items-center justify-center text-3xl lg:text-5xl"
      onclick={() => {
        if (window.confirm(`Er du sikker på at du vil sette alle bestillinger som utlevert?`)) {
          void setAllOrdersState(State.dispatched);
        }
      }}
      >Nullstill bestillinger
    </button>
  </li>
  {#each adminPages as page (page.href)}
    <li>
      <a
        class="btn relative m-4 flex h-24 w-full flex-col items-center justify-center text-3xl lg:text-5xl"
        href={resolve(page.href)}
        >{page.text}
      </a>
    </li>
  {/each}
</ul>
