var selenium = require('selenium-server-standalone-jar');
var chromedriver = require('chromedriver');

var chromeOptions = []
if (process.env.RAILS_ENV == 'test') {
  console.log("WORD UP!!!!!!!!! running in HEADLESS MODE")
  chromeOptions = [ "headless" ]
}

module.exports = {
  src_folders: ['./tests/e2e/specs'],
  output_folder: './tests/reports',
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
      screenshots: {
        enabled: true,
        path: "./tests/reports/",
        on_failure: true,
        on_error: true
      },
      launch_url: "about:blank",
      skip_testcases_on_fail: false,
      selenium_port: 4444,
      selenium_host: 'localhost',
      desiredCapabilities: {
        browserName: 'chrome',
        chromeOptions : { args: chromeOptions },
        javascriptEnabled: true,
        acceptSslCerts: true
      },
    }
  }
};
