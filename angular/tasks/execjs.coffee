# writes dist/javascripts/execjs(.min).js
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'
expect   = require 'gulp-expect-file'

module.exports = ->
  pipe gulp.src(paths.js.execjs), [
    expect({errorOnFailure: true}, paths.js.execjs), # ensure all execjs files are present
    concat('execjs.js'),                      # concatenate execjs files
    gulp.dest(paths.dist.assets),             # write assets/execjs.js
    uglify(),                                 # minify vendor.js
    rename(suffix: '.min'),                   # rename stream to vendor.min.js
    gulp.dest(paths.dist.assets)              # write assets/vendor.min.js
  ]
