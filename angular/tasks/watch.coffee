# watches and reload changes
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'

module.exports = ->
  gulp.watch paths.js.vendor, ['vendor']
  gulp.watch [paths.core.coffee, paths.core.haml], ['app']
  gulp.watch [paths.core.scss_watch], ['scss']
