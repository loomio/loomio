# runs protractor e2e tests
paths      = require './paths'
gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
protractor = require('gulp-protractor').protractor

module.exports = ->
  pipe gulp.src(paths.protractor.specs), [
    protractor(configFile: paths.protractor.config)
  ]
