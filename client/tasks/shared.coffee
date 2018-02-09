gulp    = require 'gulp'
pipe    = require 'gulp-pipe'
replace = require 'gulp-replace'
paths   = require './paths.coffee'

module.exports =
  fonts: ->
    gulp.src(paths.shared.fonts).pipe(gulp.dest(paths.dist.fonts))

  emoji: ->
    gulp.src(paths.shared.emojis).pipe(gulp.dest(paths.dist.emojis))

  moment_locales: ->
    pipe gulp.src(paths.shared.moment_locales), [
      replace(/;\(function \(global, factory\) {(.|\n)*function \(moment\) {\s*/, ""),
      replace(/}\)\)\);(.|\n)*$/, ""),
      replace(/return\s[a-z]*;\n*$/, ""),
      gulp.dest(paths.dist.moment_locales)
    ]
