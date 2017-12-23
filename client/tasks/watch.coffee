# watches and reload changes
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'

module.exports = ->
  gulp.watch paths.js.vendor,     ['angular:vendor']
  gulp.watch paths.app.coffee,    ['angular:app_coffee']
  gulp.watch paths.app.haml,      ['angular:app_haml']
  gulp.watch paths.app.scss,      ['angular:app_scss']
  gulp.watch paths.plugin.coffee, ['angular:plugin_coffee']
  gulp.watch paths.plugin.haml,   ['angular:plugin_coffee']
  gulp.watch paths.plugin.scss,   ['angular:plugin_scss']
  gulp.watch paths.vue.vue,       ['vue:compile-fast']
  gulp.watch paths.vue.coffee,    ['vue:compile-fast']
