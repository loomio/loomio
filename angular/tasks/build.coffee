# writes dist/app(.min).css
paths  = require './paths'
gulp   = require 'gulp'
pipe   = require 'gulp-pipe'

module.exports = ->
  pipe gulp.src(paths.dist.all), [
    gulp.dest(paths.public) # copy dist folder to public
  ]
