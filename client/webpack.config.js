const path = require('path');

module.exports = {
  mode: 'development',
  entry: './angular/main.coffee',
  devtool: 'inline-source-map',
  resolve: {
    extensions: [ '.js', '.coffee' ],
    modules: [path.resolve(__dirname), path.resolve(__dirname, 'node_modules')],
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },
  output: {
    path: path.resolve(__dirname, '../public/client/webpack'),
    filename: 'app.bundle.js'
  },
  module: {
    rules: [
      { test: /\.haml$/, loader: "haml" }
      { test: /\.coffee$/,
        use: [ {
                 loader: 'coffee-loader',
                 options: { transpile: { presets: ['@babel/env'] }}
               } ]}]
  }
};
