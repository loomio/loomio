import { defineConfig } from 'vite';
import path from 'path';
import { createVuePlugin } from 'vite-plugin-vue2';
import envCompatible from 'vite-plugin-env-compatible';
import { createHtmlPlugin } from 'vite-plugin-html';
import { viteCommonjs } from '@originjs/vite-plugin-commonjs';
import ViteYaml from '@modyfi/vite-plugin-yaml';
import { VuetifyResolver } from 'unplugin-vue-components/resolvers';
import Components from 'unplugin-vue-components/vite';


import LoomioComponents from './src/components.js';

function LoomioVueResolver() {
  return {
    type: "component",
    resolve: (name) => {
      if (LoomioComponents[name]) {
        return { default: name, from: '/src/components/'+LoomioComponents[name]+'.vue' };
      }
    }
  };
}

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    fs: {
      allow: ['..']
    },
    port: 8080,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        configure: (proxy, options) => {
          // proxy will be an instance of 'http-proxy'
        },
      },
    },
  },
  resolve: {
    alias: [
      {
        find: /^~/,
        replacement: ''
      },
      {
        find: '@',
        replacement: path.resolve(__dirname, 'src')
      },
      {
        find: './locales',
        replacement: path.resolve(__dirname, '../../config/locales')
      }
    ],
    extensions: [
      '.mjs',
      '.js',
      '.ts',
      '.jsx',
      '.tsx',
      '.json',
      '.vue'
    ]
  },
  plugins: [
    createVuePlugin(),
    Components({
      directoryAsNamespace: true,
      resolvers: [
        LoomioVueResolver(),
        VuetifyResolver(),
      ],
    }),
    viteCommonjs(),
    envCompatible(),
    createHtmlPlugin({
      inject: {
        data: {
          title: 'vue'
        }
      }
    }),
    ViteYaml(),
  ],
  build: {
    rollupOptions: {
      external: ['/roboto.css', '/materialdesignicons.css', '/thumbicons.css']
    }
  }
})
