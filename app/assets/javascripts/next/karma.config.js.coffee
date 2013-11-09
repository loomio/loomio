module.exports = (config) ->
  config.set
    preprocessors:
      "**/*.js.coffee": ["coffee"]

    # base path, that will be used to resolve files and exclude
    basePath: ""

    # frameworks to use
    frameworks: ["jasmine"]

    # list of files / patterns to load in the browser
    files: [
      "../../../../vendor/assets/bower_components/jquery/jquery.js",
      "../../../../vendor/assets/bower_components/angular/angular.js",
      "../../../../vendor/assets/bower_components/angular-mocks/angular-mocks.js",
      "app/loomio_app.js.coffee",
      "app/add_comment.js.coffee",
      "test/*_spec.js.coffee",
      "test/unit/*_spec.js.coffee"]

    # list of files to exclude
    exclude: []

    # test results reporter to use
    # possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ["progress"]

    # web server port
    port: 9876

    # enable / disable colors in the output (reporters and logs)
    colors: true

    # level of logging
    # possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true
    browsers: []

    # If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: false

