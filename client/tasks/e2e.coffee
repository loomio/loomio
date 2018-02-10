# runs protractor e2e tests for core app
paths      = require './paths'
gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
protractor = require('gulp-protractor').protractor
nightwatch = require 'gulp-nightwatch'

module.exports =
  protractor:
    core: ->
      pipe gulp.src(paths.protractor.specs.core), [
        protractor(configFile: paths.protractor.config)
      ]

    plugins: ->
      pipe gulp.src(paths.protractor.specs.plugins), [
        protractor(configFile: paths.protractor.config)
      ]
  nightwatch:
    core: ->
      pipe gulp.src(paths.nightwatch.specs), [
        nightwatch(configFile: paths.nightwatch.config)
      ]
