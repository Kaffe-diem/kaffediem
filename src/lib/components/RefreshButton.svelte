<script lang="ts">
  import RefreshIcon from "$assets/RefreshIcon.svelte";
  import { resetStores } from "$lib/stores/util";

  function reset() {
    resetStores();
    window.alert("Lastet inn på nytt!");
  }
</script>

<button onclick={reset} class="btn btn-lg btn-secondary"><RefreshIcon /></button>
