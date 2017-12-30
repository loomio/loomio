# watches and reload changes
paths    = require './paths'
gulp     = require 'gulp'

module.exports = ->
  gulp.watch paths.angular.haml,   ['angular:core:haml']
  gulp.watch paths.angular.scss,   ['angular:core:scss']
