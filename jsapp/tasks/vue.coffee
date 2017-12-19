gulp       = require 'gulp'
browserify = require 'browserify'
vueify     = require 'vueify'
uglify     = require 'gulp-uglify'
coffeeify  = require 'coffeeify'
source     = require 'vinyl-source-stream'
paths      = require './paths'

module.exports = ->
  browserify(entries: [paths.vue.coffee])
    .transform(coffeeify)
    .transform(vueify)
    .plugin('vueify-extract-css', { out: "#{paths.dist.assets}/vue.css" })
    .bundle()
    .pipe(source('vue.js'))
    .pipe(gulp.dest(paths.dist.assets))
