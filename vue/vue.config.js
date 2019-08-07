const components = require('./src/components.js')
const path = require('path')

module.exports = {
  chainWebpack: config => {
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
    }

  },
  outputDir: '../public/client/vue',
  assetsDir: '../../client/vue',
  devServer: {
   proxy: {
     '^/(api|dev|login_tokens|theme|fonts|img|join|invitations|system|direct_uploads|rails|slack|oauth|facebook|google)': {target: 'http://localhost:3000'},
     '^/(cable)': {target: 'ws://localhost:3000', ws: true, secure: false, changeOrigin: true},
   }
  },
  css: {
    loaderOptions: {
      sass: {
        includePaths: ["src/css", "node_modules/"],
        data: `@import "main.scss"`,
      },
      postcss: {
        // options here will be passed to postcss-loader
      }
    }
  }
}
