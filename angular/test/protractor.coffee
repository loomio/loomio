screenshooter = require('protractor-jasmine2-screenshot-reporter');
paths         = require('../tasks/paths')

exports.config =
  allScriptsTimeout: 30000
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
    defaultTimeoutInterval: 30000
  onPrepare: ->
    jasmine.getEnv().addReporter new screenshooter
      dest: paths.protractor.screenshots
      captureOnlyFailedSpecs: true
      filename: 'index.html'
