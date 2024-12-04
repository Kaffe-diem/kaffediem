<script>
  import { goto } from '$app/navigation';
  let { children } = $props();

  const redirectToPrevious = () => {
    const length = $state(window.location.pathname.split('/').length);
    let href = "";
    for (let i = 0; i < length - 2; i++) {
      href += '.';
    }
    href += '/';
    goto(href);
  }
</script>

<main class="relative mx-auto w-11/12 py-4">
  {@render children?.()}
</main>

<div class="absolute bottom-0 right-0 m-8 hidden md:flex">
  <a onclick={redirectToPrevious} class="btn btn-secondary">Tilbake</a>
</div>
