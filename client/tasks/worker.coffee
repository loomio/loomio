browserify = require 'browserify'
paths      = require './paths'
onError    = require './onerror'
gulp       = require 'gulp'
buffer     = require 'vinyl-buffer'
coffeeify  = require 'coffeeify'
source     = require 'vinyl-source-stream'
collapse   = require 'bundle-collapser/plugin'

module.exports =
  development: ->
    browserify(browserifyOpts())
      .bundle()
      .pipe(source('service-worker.js'))
      .on('error', onError)
      .pipe(gulp.dest(paths.dist.root))

  production: ->
    browserify(browserifyOpts())
      .plugin(collapse)
      .bundle()
      .pipe(source('service-worker.js'))
      .pipe(buffer())
      .on('error', onError)
      .pipe(gulp.dest(paths.dist.root))

browserifyOpts = ->
  entries: paths.worker.main
  transform: [coffeeify]
  standalone: 'service-worker'
