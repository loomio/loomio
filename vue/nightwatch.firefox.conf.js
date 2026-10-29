const config = require('./nightwatch.conf');

// Keep the browser driver separate from the development Hocuspocus port.
config.test_settings.default.webdriver.port = 9516;
config.test_settings.default.desiredCapabilities = {
  browserName: 'firefox',
  'moz:firefoxOptions': {args: ['-headless']}
};

module.exports = config;
