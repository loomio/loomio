const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  mode: 'development',
  entry: ['./vue/main.coffee'],
  devtool: 'inline-source-map',
  resolve: {
    extensions: [ '.js', '.coffee', '.haml'],
    modules: [path.resolve(__dirname), path.resolve(__dirname, 'node_modules')],
    alias: {
      'vue$': 'vue/dist/vue.runtime.esm.js'
    }
  },
  output: {
    path: path.resolve(__dirname, '../public/client/webpack'),
    filename: 'app.bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.(scss|css)$/,
        use: [
          {loader: 'vue-style-loader'},
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
  plugins: [ new VueLoaderPlugin() ]
};
