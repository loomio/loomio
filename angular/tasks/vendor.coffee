# writes dist/javascripts/vendor(.min).js
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'
expect   = require 'gulp-expect-file'

module.exports = ->
  pipe gulp.src(paths.js.vendor), [
    expect({errorOnFailure: true}, paths.js.vendor), # ensure all vendor files are present
    concat('vendor.js'),                      # concatenate vendor files
    gulp.dest(paths.dist.assets),             # write assets/vendor.js
    uglify(),                                 # minify vendor.js
    rename(suffix: '.min'),                   # rename stream to vendor.min.js
    gulp.dest(paths.dist.assets)              # write assets/vendor.min.js
  ]
