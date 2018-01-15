gulp  = require 'gulp'
paths = require './paths.coffee'

module.exports =
  fonts: ->
    gulp.src(paths.shared.fonts).pipe(gulp.dest(paths.dist.fonts))

  emoji: ->
    gulp.src(paths.shared.emojis).pipe(gulp.dest(paths.dist.emojis))

  moment_locales: ->
    gulp.src(paths.shared.moment_locales).pipe(gulp.dest(paths.dist.moment_locales))
