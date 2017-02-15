# writes dist/javascripts/execjs(.min).js
paths    = require './paths'
gulp     = require 'gulp'
append   = require 'add-stream'
pipe     = require 'gulp-pipe'
coffee   = require 'gulp-coffee'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'
expect   = require 'gulp-expect-file'

module.exports = ->
  pipe gulp.src(paths.js.execjs), [
    expect({errorOnFailure: true}, paths.js.execjs), # ensure all execjs files are present
    append.obj(pipe gulp.src(paths.js.execcoffee), [
      coffee({bare: true})                    # convert initializers to js
    ])
    concat('execjs.js'),                      # concatenate execjs files
    gulp.dest(paths.dist.assets),             # write assets/execjs.js
    rename(suffix: '.min'),                   # rename stream to vendor.min.js
    gulp.dest(paths.dist.assets)              # write assets/vendor.min.js
  ]
