# writes dist/stylesheets/app.css
paths   = require './paths'
onError = require './onerror'
gulp    = require 'gulp'
pipe    = require 'gulp-pipe'
plumber = require 'gulp-plumber'
concat  = require 'gulp-concat'
sass    = require 'gulp-sass'
cssmin  = require 'gulp-cssmin'
rename  = require 'gulp-rename'
replace = require 'gulp-replace'

module.exports = ->
  pipe gulp.src(paths.core.scss), [
    plumber(errorHandler: onError),                # handle errors gracefully
    replace('screen\\0','screen'),                 # workaround for https://github.com/angular/material/issues/6304
    concat('app.css'),                             # concatenate scss files
    sass(includePaths: paths.core.scss_include),   # convert scss to css (include vendor path for @imports)
    gulp.dest(paths.dist.assets)                   # write assets/app.min.css
  ]
