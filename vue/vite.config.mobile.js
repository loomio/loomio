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
  base: './',

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

  optimizeDeps: {
    exclude: ['@emotion/is-prop-valid']
  },

  build: {
    sourcemap: true,
    emptyOutDir: true,
    outDir: 'dist',
    rollupOptions: {
      input: {
        app: path.resolve(__dirname, 'index.html'),
      },
      external: ['@emotion/is-prop-valid']
    }
  },
});
