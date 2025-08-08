import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    assetsDir: '',
    rollupOptions: {
      input: 'src/content.js',
      output: {
        entryFileNames: 'content.js',
        assetFileNames: 'style.css'
      }
    }
  }
});
