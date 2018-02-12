HtmlScreenshotReporter = require 'protractor-jasmine2-screenshot-reporter'

reporter = new HtmlScreenshotReporter
  dest: './angular/test/screenshots'
  captureOnlyFailedSpecs: true
  filename: 'my-report.html'

exports.config =
  seleniumServerJar: '../../node_modules/webdriver-manager/selenium/selenium-server-standalone-3.9.1.jar'
  allScriptsTimeout: 60000
  capabilities:
    browserName:     'firefox'
  baseUrl:           'http://localhost:3000'
  jasmineNodeOpts:
    onComplete: null
    isVerbose: false
    showColors: true
    includeStackTrace: true
    defaultTimeoutInterval: 60000

  beforeLaunch: ->
    new Promise (resolve) ->
      reporter.beforeLaunch(resolve);
  onPrepare: ->
    jasmine.getEnv().addReporter(reporter);
    browser.driver.manage().window().setSize(1680, 1624)
  afterLaunch: (exitCode) ->
    new Promise (resolve) ->
      reporter.afterLaunch(resolve.bind(this, exitCode))
