import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://jankobus.com',
  publicDir: 'public',
  outDir: 'dist',
  trailingSlash: 'always'
});
