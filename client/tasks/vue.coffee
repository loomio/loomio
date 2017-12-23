gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
browserify = require 'browserify'
vueify     = require 'vueify'
uglify     = require 'gulp-uglify'
coffeeify  = require 'coffeeify'
source     = require 'vinyl-source-stream'
expect     = require 'gulp-expect-file'
concat     = require 'gulp-concat'
paths      = require './paths'

module.exports =
  vue: ->
    browserify(entries: [paths.vue.coffee], paths: ['./node_modules', './'])
      .transform(coffeeify)
      .transform(vueify)
      .plugin('vueify-extract-css', { out: "#{paths.dist.assets}/vue.css" })
      .bundle()
      .pipe(source('vue.js'))
      .pipe(gulp.dest(paths.dist.assets))

  vendor: ->
    pipe gulp.src(paths.vue.vendor), [
      expect({errorOnFailure: true}, paths.vue.vendor), # ensure all vendor files are present
      concat('vue.vendor.js'),                          # concatenate vendor files
      gulp.dest(paths.dist.assets)                      # write assets/vue.vendor.js
    ]
