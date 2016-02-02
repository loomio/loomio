screenshooter = require('protractor-jasmine2-screenshot-reporter');
paths         = require('../tasks/paths')

exports.config =
  seleniumServerJar: '../node_modules/selenium-server-standalone-jar/jar/selenium-server-standalone-2.48.2.jar'
  specs:             paths.protractor.specs
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
