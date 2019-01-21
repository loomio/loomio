const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const VuetifyLoaderPlugin = require('vuetify-loader/lib/plugin')

module.exports = {
  mode: 'development',
  entry: ['./vue/main.coffee'],
  devtool: 'inline-source-map',
  resolve: {
    extensions: [ '.js', '.coffee', '.haml'],
    modules: [path.resolve(__dirname), path.resolve(__dirname, 'node_modules')],
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },
  output: {
    path: path.resolve(__dirname, '../public/client/webpack'),
    filename: 'app.js'
  },
  module: {
    rules: [
      {
        test: /\.(scss|css)$/,
        use: [
          process.env.NODE_ENV !== 'production'
            ? {loader: 'vue-style-loader'}
            : {loader: MiniCssExtractPlugin.loader} ,
          {loader: 'css-loader'},
          {loader: 'sass-loader',
           options: { includePaths: ["angular/css", "node_modules/mdi/scss"]}
          }
        ],
      },
      { test: /\.html$/, use: 'vue-template-loader' },
      {
        test: /\.vue$/,
        loader: 'vue-loader'
      },
      { test: /\.haml$/,
        use: [{loader: path.resolve(__dirname, 'tasks/haml-loader.js')}]
       },
      { test: /\.coffee$/,
        use: [ {
                 loader: 'coffee-loader',
                 options: { transpile: { presets: ['@babel/env'] }}
               } ]}]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "app.css"
    }),
    new VueLoaderPlugin(),
    new VuetifyLoaderPlugin(
      // forEach(ComponentPaths, (path, name) -> {
      //   match (originalTag, { kebabTag, camelTag, path, component }) {
      //     if (kebabTag.startsWith('core-')) {
      //       return [camelTag, `import ${camelTag} from '@/components/core/${camelTag.substring(4)}.vue'`]
      //     }
      //   }
      // })
    )
  ]
};
