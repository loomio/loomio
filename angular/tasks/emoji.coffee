# writes dist/javascripts/app(.min).js
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'

module.exports = ->
  pipe gulp.src(paths.core.emojis), [
    gulp.dest(paths.dist.emojis)                 # write public/img/emoji
  ]
