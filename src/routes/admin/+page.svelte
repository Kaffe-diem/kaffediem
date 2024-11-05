<script lang="ts">
  class NavItem {
    href: string;
    text: string;

    constructor(href: string, text: string) {
      this.href = href;
      this.text = text;
    }
  }

  const navItems = [
    new NavItem("/admin/frontdesk", "Bestillingsdisk"),
    // new NavItem("/admin/kitchen", "Kjøkken"),
    new NavItem("/display", "Visning")
    // new NavItem("/admin/screenmessage", "Endre skjerm melding"),
    // new NavItem("/admin/menu", "Endre menyen")
  ];
</script>

<ul>
  {#each navItems as item}
    <li>
      <a
        class="btn relative m-4 flex h-24 w-full flex-col items-center justify-center text-3xl lg:text-5xl"
        href={item.href}
        >{item.text}
      </a>
    </li>
  {/each}
</ul>
