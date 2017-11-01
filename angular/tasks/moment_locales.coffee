# writes dist/javascripts/app(.min).js
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'

module.exports = ->
  pipe gulp.src(paths.core.moment_locales), [
    gulp.dest(paths.dist.moment_locales)                 # write public/client/moment_locales
  ]
