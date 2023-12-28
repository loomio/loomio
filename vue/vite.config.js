import { defineConfig } from 'vite';
import path from 'path';
import vue from '@vitejs/plugin-vue'
import vuetify, { transformAssetUrls } from 'vite-plugin-vuetify'
import envCompatible from 'vite-plugin-env-compatible';
import yaml from '@originjs/vite-plugin-content';
import Components from 'unplugin-vue-components/vite';
import { splitVendorChunkPlugin } from 'vite'

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
  // css: {
  //   preprocessorOptions: {
  //     sass: {
  //       additionalData: [
  //         '@import "./src/css/variables"',
  //         '@import "vuetify/src/styles/settings/_variables"',
  //         '', // end with newline
  //       ].join('\n'),
  //     },
  //   },
  // },
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
      '^/(saml|dev|brand|login_tokens|theme|fonts|img|join|invitations|system|rails|slack|oauth|facebook|google|beta|admin|assets|upgrade|pricing|special_pricing|community_applications|417|saml_providers|merge_users|intro|bcorp|bhoy|sidekiq|message-bus|email_actions|help|bug_tunnel|contact_messages|css)/': {
        target: 'http://localhost:3000',
        changeOrigin: true,
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
    splitVendorChunkPlugin(),
    vue(),
    vuetify({
      autoImport: true
    }),
    Components({
      directoryAsNamespace: true,
      resolvers: [
        LoomioVueResolver(),
        // VuetifyResolver(),
      ],
    }),
    // viteCommonjs(),
    envCompatible(),
    yaml(),
  ],
  build: {
    sourcemap: true,
    emptyOutDir: true,
    outDir: '../public/blient',
  },
  experimental: {
    renderBuiltUrl(filename, { hostId, hostType, type } ) {
      // { hostId: string, hostType: 'js' | 'css' | 'html', type: 'public' | 'asset' }
      return '/blient/' + filename;
    }
  }
})
