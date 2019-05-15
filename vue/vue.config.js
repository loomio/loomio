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
     '/api': {target: 'http://localhost:3000'},
     '/dev': {target: 'http://localhost:3000'},
     '/login_tokens': {target: 'http://localhost:3000'},
     '/theme': {target: 'http://localhost:3000'},
     '/fonts': {target: 'http://localhost:3000'},
     '/img': {target: 'http://localhost:3000'},
     '/join': {target: 'http://localhost:3000'},
     '/invitations': {target: 'http://localhost:3000'},
     '/system': {target: 'http://localhost:3000'}
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
