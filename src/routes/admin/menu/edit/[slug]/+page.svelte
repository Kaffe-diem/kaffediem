<script lang="ts">
  import type { PageProps } from "./$types";
  import { items } from "$stores/menuStore";

  let { data }: PageProps = $props();
  const id = data.id;
  const item = $items.find((item) => item.id === id);
</script>

<div>
  <ul>
    <li>
      <input class="input" value={item.name} />
    </li>
  </ul>
</div>
