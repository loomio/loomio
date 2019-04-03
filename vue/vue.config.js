module.exports = {
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
