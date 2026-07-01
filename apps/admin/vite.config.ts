import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Dev proxy: browser calls same-origin /api/* -> backend wrangler dev on :8787.
// Avoids CORS in dev. In production the admin talks to the deployed backend URL.
export default defineConfig({
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8787',
        changeOrigin: true,
        rewrite: (p) => p.replace(/^\/api/, ''),
      },
    },
  },
  plugins: [react()],
});
