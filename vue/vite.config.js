import { defineConfig } from 'vite';
import path from 'path';
import vue from '@vitejs/plugin-vue2'
import envCompatible from 'vite-plugin-env-compatible';
// import { viteCommonjs } from '@originjs/vite-plugin-commonjs';
import ViteYaml from '@modyfi/vite-plugin-yaml';
import { VuetifyResolver } from 'unplugin-vue-components/resolvers';
import Components from 'unplugin-vue-components/vite';
import { splitVendorChunkPlugin } from 'vite'
import { VitePWA } from 'vite-plugin-pwa'

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
      '^/(pie_chart|saml|dev|brand|login_tokens|theme|fonts|files|img|join|invitations|system|rails|slack|oauth|facebook|google|beta|admin|assets|upgrade|pricing|special_pricing|community_applications|417|saml_providers|merge_users|intro|bcorp|bhoy|sidekiq|message-bus|email_actions|help|bug_tunnel|contact_messages|css)': {
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
    Components({
      directoryAsNamespace: true,
      resolvers: [
        LoomioVueResolver(),
        VuetifyResolver(),
      ],
    }),
    // viteCommonjs(),
    envCompatible(),
    ViteYaml(),
    VitePWA({
      registerType: "autoUpdate",
      injectRegister: null,
      manifest: {
        // caches the assets/icons mentioned (assets/* includes all the assets present in your src/ directory)
        includeAssets: ["favicon.ico", "apple-touch-icon.png", "assets/*"],
        name: 'Loomio',
        short_name: 'Loomio',
        start_url: '/',
        background_color: '#ffffff',
        theme_color: '#000000',
        icons: [
          {
            src: 'brand/icon_gold_256h.png',
            sizes: '256x256',
            type: 'image/png'
          }
        ]
      },
      workbox: {
        // defining cached files formats
        globPatterns: ["**/*.{js,css,html,ico,png,svg}"],
        globIgnores: ["manifest.webmanifest"],
        runtimeCaching: [
          {

            urlPattern: ({
                           request }) =>
                request.destination === 'style' ||
                request.destination === 'script' ||

                request.destination === 'worker',

            handler: 'StaleWhileRevalidate',

            options: {

              cacheName: 'static-resources',

              expiration: {

                maxEntries: 50,

                maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
              },
            },
          },
          {

            urlPattern: ({
                           request }) =>
                request.destination === 'image',

            handler: 'CacheFirst',

            options: {

              cacheName: 'images',

              expiration: {

                maxEntries: 100,

                maxAgeSeconds: 60 * 24 * 60 * 60, // 60 days
              },
            },
          },
        ],
      },
      devOptions: {
        enabled: true
      }
    }),
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
