# writes dist/fonts/*
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'

module.exports = ->
  pipe gulp.src(paths.fonts.vendor), [
    gulp.dest(paths.dist.fonts) # write public/fonts/*
  ]
