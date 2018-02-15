# runs protractor e2e tests for core app
paths      = require './paths'
gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
protractor = require('gulp-protractor').protractor
nightwatch = require 'gulp-nightwatch'
args       = require('yargs').argv

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
      pipe gulp.src('./gulpfile.coffee'), [
        nightwatch(configFile: paths.nightwatch.config, cliArgs: cliArgs())
      ]

cliArgs = ->
  result = []
  result.push "--retries #{args.retries || '1'}"
  result.push "--test ./angular/test/nightwatch/tests/#{args.test}.js" if args.test?
  result.push "--testcase #{args.testcase}"                            if args.testcase?
  result
