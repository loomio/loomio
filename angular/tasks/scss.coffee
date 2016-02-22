# writes dist/stylesheets/app(.min).css
paths  = require './paths'
gulp   = require 'gulp'
pipe   = require 'gulp-pipe'
concat = require 'gulp-concat'
sass   = require 'gulp-sass'
cssmin = require 'gulp-cssmin'
rename = require 'gulp-rename'

module.exports = ->
  pipe gulp.src(paths.core.scss), [
    concat('app.css'),                             # concatenate scss files
    sass(includePaths: paths.core.scss_include),   # convert scss to css (include vendor path for @imports)
    gulp.dest(paths.dist.assets),                  # write assets/app.css
    cssmin(),                                      # minify app.css file
    rename(suffix: '.min'),                        # rename stream to app.min.css
    gulp.dest(paths.dist.assets)                   # write assets/app.min.css
  ]
