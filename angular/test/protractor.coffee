screenshooter = require('protractor-jasmine2-screenshot-reporter');
paths         = require('../tasks/paths')

exports.config =
  seleniumAddress: 'http://localhost:4444/wd/hub'
  capabilities:
    browserName:     'firefox'
  baseUrl:           'http://localhost:3000'
  jasmineNodeOpts:
    onComplete: null
    isVerbose: false
    showColors: true
    includeStackTrace: true
  onPrepare: ->
    jasmine.getEnv().addReporter new screenshooter
      dest: paths.protractor.screenshots
      captureOnlyFailedSpecs: true
      filename: 'index.html'
