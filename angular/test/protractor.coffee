paths         = require('../tasks/paths')

exports.config =
  # seleniumServerJar: '../node_modules/webdriver-manager/selenium/selenium-server-standalone-3.3.0.jar'
  # seleniumAddress: 'http://0.0.0.0:4444/wd/hub'
  allScriptsTimeout: 40000
  directConnect: true
  # seleniumAddress: 'http://localhost:4444/wd/hub'
  capabilities:
    browserName:     'firefox'
  baseUrl:           'http://localhost:3000'
  jasmineNodeOpts:
    onComplete: null
    isVerbose: false
    showColors: true
    includeStackTrace: true
    defaultTimeoutInterval: 40000
  # onPrepare: ->
  #   jasmine.getEnv().addReporter new screenshooter
  #     dest: paths.protractor.screenshots
  #     captureOnlyFailedSpecs: true
  #     filename: 'index.html'
