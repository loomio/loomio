import { defineConfig } from 'vite';
import path from 'path';
import vue from '@vitejs/plugin-vue';
import vuetify from 'vite-plugin-vuetify';
import envCompatible from 'vite-plugin-env-compatible';
import yaml from '@originjs/vite-plugin-content';
import Components from 'unplugin-vue-components/vite';
import { viteCommonjs } from '@originjs/vite-plugin-commonjs';

import LoomioComponents from './src/components.js';

function LoomioVueResolver() {
  return {
    type: "component",
    resolve: (name) => {
      if (LoomioComponents[name]) {
        return { default: name, from: '/src/components/' + LoomioComponents[name] + '.vue' };
      }
    }
  };
}

export default defineConfig({
  server: {
    warmup: {
      clientFiles: ['./src/app.vue'],
    },
    fs: {
      allow: ['..']
    },
    port: 8080,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
      },
      '/direct_uploads': {
        target: 'http://localhost:3000',
        changeOrigin: false,
      },
      '/service-worker.js': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
      '^/(pie_chart|saml|dev|brand|login_tokens|theme|fonts|files|img|join|invitations|system|rails|slack|oauth|facebook|google|beta|admin|assets|upgrade|pricing|special_pricing|community_applications|417|saml_providers|merge_users|intro|bcorp|bhoy|sidekiq|message-bus|email_actions|help|bug_tunnel|contact_messages|css)': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
      '/cable': {
        target: 'ws://localhost:3000',
        ws: true,
      },
    },
  },

  resolve: {
    alias: [
      { find: /^~/, replacement: '' },
      { find: '@', replacement: path.resolve(__dirname, 'src') },
    ],
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.vue']
  },

  plugins: [
    vue(),
    vuetify({ autoImport: true }),
    Components({
      directoryAsNamespace: true,
      resolvers: [LoomioVueResolver()],
    }),
    viteCommonjs(),
    envCompatible(),
    yaml(),
  ],

  // --- IMPORTANT FIX ---
  optimizeDeps: {
    exclude: ['@emotion/is-prop-valid']
  },

  build: {
    sourcemap: true,
    emptyOutDir: false,
    outDir: '../public/client3',

    // Prevent Vite from treating Nightwatch HTML reports as entries
    rollupOptions: {
      input: {
        app: path.resolve(__dirname, 'index.html'),
      },
      external: ['@emotion/is-prop-valid']
    }
  },

  experimental: {
    renderBuiltUrl(filename) {
      return '/client3/' + filename;
    }
  }
});
