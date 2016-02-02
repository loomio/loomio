# writes dist/javascripts/vendor(.min).js
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'

module.exports = ->
  pipe gulp.src(paths.js.vendor), [
    concat('vendor.js'),                      # concatenate vendor files
    gulp.dest(paths.dist.javascripts),        # write javascripts/vendor.js
    uglify(),                                 # minify vendor.js
    rename(suffix: '.min'),                   # rename stream to vendor.min.js
    gulp.dest(paths.dist.javascripts)         # write javascripts/vendor.min.js
  ]
