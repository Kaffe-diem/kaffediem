<script lang="ts">
  class AdminPage {
    href: string;
    text: string;

    constructor(href: string, text: string) {
      this.href = href;
      this.text = text;
    }
  }

  const adminPages = [
    new AdminPage("/admin/frontdesk", "Bestillingsdisk"),
    new AdminPage("/admin/kitchen", "Kjøkken"),
    new AdminPage("/display", "Visning"),
    new AdminPage("/admin/message", "Endre skjermmelding")
    // new AdminPage("/admin/menu", "Endre menyen")
  ];
</script>

<ul>
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
