gulp    = require 'gulp'
pipe    = require 'gulp-pipe'
replace = require 'gulp-replace'
paths   = require './paths.coffee'

module.exports =
  emoji: ->
    gulp.src(paths.shared.emojis).pipe(gulp.dest(paths.dist.emojis))

  moment_locales: ->
    pipe gulp.src(paths.shared.moment_locales), [
      replace(/;\(function \(global, factory\) {(.|\n)*function \(moment\) {\s*/, ""),
      replace(/}\)\)\);(.|\n)*$/, ""),
      replace(/return.+\n\n$/, "\n"),
      gulp.dest(paths.dist.moment_locales)
    ]
