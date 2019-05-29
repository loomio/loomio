const components = require('./src/components.js')

module.exports = {
  chainWebpack: config => {
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
    }
  },
  outputDir: '../public/client/vue',
  assetsDir: '../../client/vue',
  devServer: {
   proxy: {
     '^/(api|dev|login_tokens|theme|fonts|img|join|invitations|system)': {target: 'http://localhost:3000'},
     '^/(cable|sockjs-node)': {target: 'ws://localhost:3000', ws: true, secure: false, changeOrigin: true},
   }
  },
  css: {
    loaderOptions: {
      sass: {
        includePaths: [ "src/css", "node_modules/" ]
      },
      postcss: {
        // options here will be passed to postcss-loader
      }
    }
  }
}
