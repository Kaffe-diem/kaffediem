<script lang="ts">
  import orders from "$stores/orderStore";
  import { State } from "$lib/types";

  class AdminPage {
    href: string;
    text: string;

    constructor(href: string, text: string) {
      this.href = href;
      this.text = text;
    }
  }

  const adminPages = [
    new AdminPage("/admin/orders/frontdesk", "Bestillingsdisk"),
    new AdminPage("/admin/orders/kitchen", "Kjøkken"),
    new AdminPage("/display", "Visning"),
    new AdminPage("/admin/message", "Endre skjermmelding"),
    new AdminPage("/admin/menu", "Rediger meny")
  ];
</script>

<ul>
  <li>
    <button
      class="btn relative m-4 flex h-24 w-full flex-col items-center justify-center text-3xl text-red-500 lg:text-5xl"
      onclick={() => {
        if (window.confirm(`Er du sikker på at du vil sette alle bestillinger som utlevert?`)) {
          orders.setAll(State.dispatched);
        }
      }}
      >Nullstill bestillinger
    </button>
  </li>
  {#each adminPages as page}
    <li>
      <a
        class="btn relative m-4 flex h-24 w-full flex-col items-center justify-center text-3xl lg:text-5xl"
        href={page.href}
        >{page.text}
      </a>
    </li>
  {/each}
</ul>
