# HtmlScreenshotReporter = require('protractor-jasmine2-screenshot-reporter');
#
# reporter = new HtmlScreenshotReporter
#   dest: 'screenshots',
#   filename: 'my-report.html'

paths         = require('../tasks/paths')

exports.config =
  # seleniumServerJar: '../node_modules/webdriver-manager/selenium/selenium-server-standalone-3.3.0.jar'
  # seleniumAddress: 'http://localhost:4444/wd/hub'
  allScriptsTimeout: 30000
  # directConnect: true
  seleniumAddress: 'http://localhost:4444/wd/hub'
  capabilities:
    browserName:     'chrome'
  baseUrl:           'http://localhost:3000'
  jasmineNodeOpts:
    onComplete: null
    isVerbose: false
    showColors: true
    includeStackTrace: true
    defaultTimeoutInterval: 30000

  # beforeLaunch: ->
  #   new Promise (resolve) ->
  #     reporter.beforeLaunch(resolve);
  #
  # onPrepare: ->
  #   jasmine.getEnv().addReporter(reporter);
  #
  # afterLaunch: (exitCode) ->
  #   new Promise (resolve) ->
  #     reporter.afterLaunch(resolve.bind(this, exitCode))
