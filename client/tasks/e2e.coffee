# runs protractor e2e tests for core app
paths      = require './paths'
gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
nightwatch = require 'gulp-nightwatch'
args       = require('yargs').argv

module.exports =
  nightwatch:
    core: ->
      pipe gulp.src('./gulpfile.coffee'), [
        nightwatch(configFile: paths.nightwatch.config.core, cliArgs: cliArgs('core'))
      ]
    plugins: ->
      pipe gulp.src('./gulpfile.coffee'), [
        nightwatch(configFile: paths.nightwatch.config.plugins, cliArgs: cliArgs('plugins'))
      ]

cliArgs = (suite) ->
  result = []
  result.push "--retries #{args.retries || '1'}"
  result.push "--test ./angular/test/nightwatch/#{suite}/#{args.test}.js" if args.test?
  result.push "--testcase #{args.testcase}"                            if args.testcase?
  result
