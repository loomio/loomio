# writes dist/javascripts/vendor.js
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
    gulp.dest(paths.dist.assets)              # write assets/vendor.js
  ]
