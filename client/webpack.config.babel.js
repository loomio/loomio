const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const VuetifyLoaderPlugin = require('vuetify-loader/lib/plugin');
const components = require('./vue/components.coffee');

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
      { test: /\.styl$/, use: ['null-loader'], },
      { test: /\.html$/, use: 'vue-template-loader' },
      { test: /\.vue$/,  loader: 'vue-loader' },
      { test: /\.pug$/,  use: 'pug-plain-loader'},
      {
        test: /\.(scss|css)$/,
        use: [
          process.env.NODE_ENV !== 'production'
            ? {loader: 'vue-style-loader'}
            : {loader: MiniCssExtractPlugin.loader} ,
          {loader: 'css-loader'},
          {loader: 'sass-loader', options: { includePaths: ["vue/css", "node_modules/mdi/scss"]}}
        ],
      },
      { test: /\.coffee$/,
        use: [ {
                 loader: 'coffee-loader',
                 options: { transpile: { presets: ['@babel/env'] }}
               } ]}]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: "app.css" }),
    new VueLoaderPlugin(),
    new VuetifyLoaderPlugin({
      /**
       * This function will be called for every tag used in each vue component
       * It should return an array, the first element will be inserted into the
       * components array, the second should be a corresponding import
       *
       * originalTag - the tag as it was originally used in the template
       * kebabTag    - the tag normalised to kebab-case
       * camelTag    - the tag normalised to PascalCase
       * path        - a relative path to the current .vue file
       * component   - a parsed representation of the current component
       */

      match (originalTag, { kebabTag, camelTag, path, component }) {
        if (components[camelTag]) {
          return [camelTag, `import ${camelTag} from 'vue/components/${components[camelTag]}.vue'`]
        }
      }
    })
  ]
};
