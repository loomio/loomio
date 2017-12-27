# writes dist/javascripts/execjs(.min).js
paths    = require './paths'
gulp     = require 'gulp'
append   = require 'add-stream'
pipe     = require 'gulp-pipe'
coffee   = require 'gulp-coffee'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'
expect   = require 'gulp-expect-file'

module.exports =
  development: ->
    pipe gulp.src(paths.js.execjs), [
      expect({errorOnFailure: true}, paths.js.execjs),
      append.obj(pipe gulp.src(paths.js.execcoffee), [coffee(bare: true)])
      concat('execjs.js'),
      gulp.dest(paths.dist.assets)
    ]

  production: ->
    pipe gulp.src(paths.js.execjs), [
      expect({errorOnFailure: true}, paths.js.execjs),
      append.obj(pipe gulp.src(paths.js.execcoffee), [coffee(bare: true)])
      concat('execjs.min.js'),
      uglify(mangle: false),
      gulp.dest(paths.dist.assets)
    ]
