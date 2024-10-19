<script>
  const navItems = [
    { href: "/drinks", text: "Meny" },
    { href: "/display", text: "Visning" },
    { href: "/auth", text: "Logg inn" }
  ];
</script>

<div class="navbar bg-base-100">
  <div class="flex-1">
    <a href="/" class="btn btn-ghost text-xl">Kaffe Diem</a>
  </div>
  <div class="flex-none">
    <ul class="menu menu-horizontal px-1">
      {#each navItems as item}
        <li>
          <a href={item.href}>{item.text}</a>
        </li>
      {/each}
    </ul>
  </div>
</div>
