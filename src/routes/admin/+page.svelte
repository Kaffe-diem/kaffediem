<script lang="ts">
  import orders from "$stores/orderStore";
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

  let isAnimating = $state(false);

  function handleReset() {
    if (window.confirm(`Er du sikker på at du vil sette alle bestillinger som utlevert?`)) {
      isAnimating = true;
      orders.setAll(State.dispatched);
      setTimeout(() => {
        isAnimating = false;
      }, 600);
    }
  }
</script>

<ul>
  <li>
    <button
      class="btn btn-error relative m-4 flex h-24 w-full flex-col items-center justify-center text-3xl lg:text-5xl {isAnimating ? 'explosion' : ''}"
      onclick={handleReset}
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

<style>
  @keyframes explosion {
    0% {
      transform: scale(1) rotate(0deg);
      opacity: 1;
    }
    25% {
      transform: scale(0.95) rotate(-2deg);
    }
    50% {
      transform: scale(1.15) rotate(2deg);
      box-shadow: 0 0 20px 10px rgba(239, 68, 68, 0.5);
    }
    75% {
      transform: scale(1.05) rotate(-1deg);
      box-shadow: 0 0 40px 20px rgba(239, 68, 68, 0.3);
    }
    100% {
      transform: scale(1) rotate(0deg);
      opacity: 1;
      box-shadow: 0 0 0 0 rgba(239, 68, 68, 0);
    }
  }

  :global(.explosion) {
    animation: explosion 0.6s ease-out;
  }
</style>
