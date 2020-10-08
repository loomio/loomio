const components = require('./src/components.js')
const path = require('path')
const VuetifyLoaderPlugin = require('vuetify-loader/lib/plugin');
module.exports = env => {
  return {
    chainWebpack: config => {
      config.module.rule('vue').use('vue-loader').tap(args => { args.compilerOptions.whitespace = 'preserve' })
      config.module.rule('yml').test(/\.yml$/).use('js-yaml-loader').loader('js-yaml-loader').end()
      config.module.rule('yml').test(/\.yml$/).use('single-curlys-loader').loader('single-curlys-loader').end()
      config.plugins.delete('prefetch');
      config
      .plugin('VuetifyLoaderPlugin')
      .tap(args => {
          return [{
              match (originalTag, { kebabTag, camelTag, path, component }) {
                if (components[camelTag]) {
                  return [camelTag, `import ${camelTag} from '@/components/${components[camelTag]}.vue'`]
                }
              }
          }]
      })
    },
    configureWebpack: {
      entry: {
        'app': './src/main.coffee'
      },
      resolveLoader: {
        alias: {
          'single-curlys-loader': path.join(__dirname, 'loaders', 'single_curlys.js')
        }
      },
      // plugins: [
      //   new VuetifyLoaderPlugin({
      //     match (originalTag, { kebabTag, camelTag, path, component }) {
      //       if (components[camelTag]) {
      //         return [camelTag, `import ${camelTag} from '@/components/${components[camelTag]}.vue'`]
      //       }
      //     }
      //   })
      // ],
    },
    outputDir: '../public/blient/vue',
    assetsDir: (process.env.NODE_ENV == 'production') ? '../../blient/vue' : 'blient/vue',
    devServer: {
     proxy: {
     '^/(api|dev|login_tokens|theme|fonts|img|join|invitations|system|direct_uploads|rails|slack|oauth|facebook|google|beta|admin|assets|upgrade|pricing|special_pricing|community_applications|417|saml_providers|merge_users|intro|bcorp|bhoy|sidekiq|message-bus|email_actions)': {target: 'http://localhost:3000'},
       '^/(cable)': {target: 'ws://localhost:3000', ws: true, secure: false, changeOrigin: true},
     }
    },
    css: {
      loaderOptions: {
        sass: {
          sassOptions: {
            includePaths: ["src/css", "node_modules/"]
          },
          additionalData: "@import '@/css/variables.scss'"
        }
      }
    }
  }
}
