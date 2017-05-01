# HtmlScreenshotReporter = require('protractor-jasmine2-screenshot-reporter');
#
# reporter = new HtmlScreenshotReporter
#   dest: 'screenshots',
#   filename: 'my-report.html'

paths         = require('../tasks/paths')

exports.config =
  seleniumServerJar: '../node_modules/webdriver-manager/selenium/selenium-server-standalone-3.4.0.jar'
  allScriptsTimeout: 40000
  capabilities:
    browserName:     'firefox'
  baseUrl:           'http://localhost:3000'
  jasmineNodeOpts:
    onComplete: null
    isVerbose: false
    showColors: true
    includeStackTrace: true
    defaultTimeoutInterval: 40000

  # beforeLaunch: ->
  #   new Promise (resolve) ->
  #     reporter.beforeLaunch(resolve);
  #
  onPrepare: ->
    # jasmine.getEnv().addReporter(reporter);
    browser.driver.manage().window().setSize(1680, 1024)
  #
  # afterLaunch: (exitCode) ->
  #   new Promise (resolve) ->
  #     reporter.afterLaunch(resolve.bind(this, exitCode))
