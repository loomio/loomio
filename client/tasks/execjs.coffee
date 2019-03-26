browserify = require 'browserify'
paths      = require './paths'
onError    = require './onerror'
gulp       = require 'gulp'
buffer     = require 'vinyl-buffer'
coffeeify  = require 'coffeeify'
source     = require 'vinyl-source-stream'
collapse   = require 'bundle-collapser/plugin'
uglify     = require('gulp-uglify/composer')(require('uglify-es', console))

module.exports =
  development: ->
    browserify(browserifyOpts())
      .bundle()
      .pipe(source('execjs.bundle.js'))
      .on('error', onError)
      .pipe(gulp.dest(paths.dist.assets))

  production: ->
    browserify(browserifyOpts())
      .transform('uglifyify', global: true)
      .plugin(collapse)
      .bundle()
      .pipe(source('execjs.bundle.min.js'))
      .pipe(buffer())
      .pipe(uglify())
      .on('error', onError)
      .pipe(gulp.dest(paths.dist.assets))

browserifyOpts = ->
  entries: paths.execjs.main
  extensions: ['.coffee', '.js']
  transform: [coffeeify]
  standalone: 'execjs'
