var selenium = require('selenium-server-standalone-jar');
var chromedriver = require('chromedriver');

module.exports = {
  src_folders: ['./tests/e2e/specs'],
  output_folder: './tests/e2e/reports',
  selenium: {
    start_process: true,
    server_path: selenium.path,
    log_path: './tests/reports',
    cli_args: {
      'webdriver.chrome.driver': chromedriver.path,
      'webdriver.ie.driver': ''
    }
  },
  test_settings: {
    default: {
      "screenshots" : {
        "enabled" : false,
        "path" : "./tests/e2e/reports/",
        "on_failure": true
        "on_error": true
      },
      launch_url: 'http://localhost:8080/',
      selenium_port: 4444,
      selenium_host: 'localhost',
      desiredCapabilities: {
        browserName: 'chrome',
        javascriptEnabled: true,
        acceptSslCerts: true
      },
    }
  },
  "chrome" : {
    "desiredCapabilities" : {
      "browserName" : "chrome",
      "chromeOptions" : {
        "args" : [
          "use-fake-device-for-media-stream",
          "use-fake-ui-for-media-stream"
        ]
      }
    }
  }
};
