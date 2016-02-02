# watches and reload changes
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'

module.exports = ->
  gulp.watch paths.js.vendor, ['vendor']
  gulp.watch [paths.js.core, paths.html.core], ['app']
  gulp.watch paths.css.core, ['scss']
