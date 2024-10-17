<script>
  import "../app.css";

  const navItems = [
    { href: "/drinks", text: "Meny" },
    { href: "/display", text: "Visning" }
  ];
</script>

<div class="app w-8/12 mx-auto">
  <header class="flex py-2 items-center justify-between">
    <h1 class="text-4xl font-bold">
      <a href="/">Kaffe Diem</a>
    </h1>
    <nav>
      <ul class="flex items-center space-x-4">
        {#each navItems as item}
          <li>
            <a href={item.href} class="hover:underline">{item.text}</a>
          </li>
        {/each}
      </ul>
    </nav>
  </header>
  <main>
    <slot />
  </main>
</div>
