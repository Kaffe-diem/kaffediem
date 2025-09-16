<script>
  import { resolve } from "$app/paths";
  import Logo from "$assets/logo.png";
  const year = new Date().getFullYear();
</script>

<footer class="footer bg-base-200 text-base-content mt-10 p-10">
  <aside>
    <img src={Logo} alt="logo" class="mb-2 w-24 rounded-xl" />
    <p>
      Copyright © {year} Kaffe diem
      <br />
      Den beste kaffeen på Amalie Skram VGS
    </p>
  </aside>
  <nav>
    <h6 class="footer-title">Vilkår og personvern</h6>
    <a href={resolve("/tos")} class="link-hover link">Vilkår for bruk</a>
  </nav>
  <nav>
    <h6 class="footer-title">Få hjelp</h6>
    <a href="mailto:kaffediem@asvg.no" class="link-hover link">Kontakt oss</a>
  </nav>
  <nav>
    <h6 class="footer-title">Annet</h6>
    <a href={resolve("/display")} class="link-hover link">Visning</a>
  </nav>
</footer>
