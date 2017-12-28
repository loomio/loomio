# watches and reload changes
paths    = require './paths'
gulp     = require 'gulp'

module.exports = ->
  gulp.watch paths.js.vendor,      ['angular:vendor']
  gulp.watch paths.core.haml,      ['angular:core:haml']
  gulp.watch paths.core.scss,      ['angular:core:scss']
  gulp.watch paths.plugin.haml,    ['angular:plugin:haml']
  gulp.watch paths.plugin.scss,    ['angular:plugin:scss']
