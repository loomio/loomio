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
   proxy: 'http://localhost:3000'
  },
  css: {
    loaderOptions: {
      sass: {
        includePaths: [ "src/css", "node_modules/@mdi/font" ]
      },
      postcss: {
        // options here will be passed to postcss-loader
      }
    }
  }
}
