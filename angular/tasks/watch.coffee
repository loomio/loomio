# watches and reload changes
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'

module.exports = ->
  gulp.watch paths.js.vendor,     ['vendor']
  gulp.watch paths.app.coffee,    ['app_coffee']
  gulp.watch paths.app.scss,      ['app_scss']
  gulp.watch paths.plugin.coffee, ['plugin_scss']
  gulp.watch paths.plugin.scss,   ['plugin_coffee']
