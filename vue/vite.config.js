import { defineConfig } from 'vite';
import path from 'path';
import { createVuePlugin } from 'vite-plugin-vue2';
import envCompatible from 'vite-plugin-env-compatible';
import { viteCommonjs } from '@originjs/vite-plugin-commonjs';
import ViteYaml from '@modyfi/vite-plugin-yaml';
import { VuetifyResolver } from 'unplugin-vue-components/resolvers';
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
      '^/(saml|dev|brand|login_tokens|theme|fonts|img|join|invitations|system|direct_uploads|rails|slack|oauth|facebook|google|beta|admin|assets|upgrade|pricing|special_pricing|community_applications|417|saml_providers|merge_users|intro|bcorp|bhoy|sidekiq|message-bus|email_actions|help|bug_tunnel|contact_messages|css)/': {
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
    ViteYaml(),
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
