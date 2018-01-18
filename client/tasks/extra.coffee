# writes dist/javascripts/app(.min).js
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
append   = require 'add-stream'
coffee   = require 'gulp-coffee'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'
expect   = require 'gulp-expect-file'

module.exports =
  fonts: ->
    pipe gulp.src(paths.extra.fonts), [
      gulp.dest(paths.dist.fonts) # write public/fonts/*
    ]

  emoji: ->
    pipe gulp.src(paths.extra.emojis), [
      gulp.dest(paths.dist.emojis) # write public/img/emoji
    ]

  moment_locales: ->
    pipe gulp.src(paths.extra.moment_locales), [
      gulp.dest(paths.dist.moment_locales) # write public/client/moment_locales
    ]
