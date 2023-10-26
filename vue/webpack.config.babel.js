const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const VuetifyLoaderPlugin = require('vuetify-loader/lib/plugin');
const components = require('./src/components');

module.exports = {
  mode: 'development',
  entry: ['./src/main'],
  devtool: 'inline-source-map',
  resolve: {
    extensions: [ '.js'],
    modules: [path.resolve(__dirname), path.resolve(__dirname, 'node_modules')],
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },
  output: {
    path: path.resolve(__dirname, '../public/blient/vue/webpack'),
    filename: 'app.js'
  },
  module: {
    rules: [
      { test: /\.html$/, use: 'vue-template-loader' },
      { test: /\.vue$/,  loader: 'vue-loader' },
      { test: /\.pug$/,  use: 'pug-plain-loader'},
  },
  plugins: [
    new WebpackNightWatchPlugin({
      url: './tests/e2e/nightwatch.conf.js'
    }),
  ]
};
