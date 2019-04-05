module.exports = {
  indexPath: 'vue.html',
  devServer: {
   proxy: 'http://localhost:3000'
  },
  css: {
    loaderOptions: {
      sass: {
        includePaths: [ "src/css", "node_modules/@mdi/font/scss" ]
      },
      postcss: {
        // options here will be passed to postcss-loader
      }
    }
  }
}
