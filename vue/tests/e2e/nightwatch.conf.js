// var selenium = require('selenium-server-standalone-jar');
var chromedriver = require('chromedriver');

var chromeOptions = ["window-size=1280,1500"]

if (process.env.RAILS_ENV == 'test' || 
    process.env.CHROME_HEADLESS ) { chromeOptions.push("headless") }

module.exports = {
  detailed_output: false,
  src_folders: ['./tests/e2e/specs'],
  output_folder: './tests/reports',
  selenium: {
    start_process: false
  },
  webdriver: {
    start_process: true,
    server_path: "node_modules/.bin/chromedriver",
    cli_args: ["--verbose"]
  },
  test_settings: {
    default: {
      screenshots: {
        enabled: true,
        path: "./tests/screenshots/",
        on_failure: true,
        on_error: true
      },
      launch_url: "about:blank",
      skip_testcases_on_fail: false,
      desiredCapabilities: {
        browserName: 'chrome',
        chromeOptions : { w3c: false, args: chromeOptions },
        javascriptEnabled: true,
        acceptSslCerts: true,
        loggingPrefs: { 'browser': 'ALL' }
      },
    }
  }
};
