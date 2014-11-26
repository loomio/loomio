'use strict';

module.exports = function(config) {
    config.set({
        frameworks: ['jasmine'],

        // list of files / patterns to load in the browser
        files: [
            'bower_components/angular/angular.js',
            'bower_components/angular-mocks/angular-mocks.js',
            'src/*.js',
            'tests/**/*.js'
        ],

        // list of files to exclude
        exclude: [],

        preprocessors: {
            './src/**/*.js': 'coverage'
        },

        // use dots reporter, as travis terminal does not support escaping sequences
        // possible values: 'dots', 'progress'
        // CLI --reporters progress

        // remove 'coverage' for inline debugging of directive source
        reporters: ['junit','progress','coverage','threshold'],

        junitReporter: {
            outputFile: 'test-reports/junit.xml',
            suite: 'ment.io'
        },

        thresholdReporter: {
            statements: 0,
            branches: 0,
            functions: 0,
            lines: 0
        },

        coverageReporter: {
              type: 'lcov',
              dir:'coverage/'
        },

        // web server port
        // CLI --port 9876
        port: 8085,

        // enable / disable colors in the output (reporters and logs)
        // CLI --colors --no-colors
        colors: true,

        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR ||
        // config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        // CLI --log-level debug
        logLevel: config.LOG_INFO,

        // enable / disable watching file and executing tests whenever any file changes
        // CLI --auto-watch --no-auto-watch
        autoWatch: false,

        // Start these browsers, currently available:
        // - Chrome
        // - ChromeCanary
        // - Firefox
        // - Opera
        // - Safari (only Mac)
        // - PhantomJS
        // - IE (only Windows)
        // CLI --browsers Chrome,Firefox,Safari
        browsers: ['PhantomJS'],

        // If browser does not capture in given timeout [ms], kill it
        // CLI --capture-timeout 5000
        captureTimeout: 20000,

        // Auto run tests on start (when browsers are captured) and exit
        // CLI --single-run --no-single-run
        singleRun: false,

        // report which specs are slower than 500ms
        // CLI --report-slower-than 500
        reportSlowerThan: 500

    });
};

