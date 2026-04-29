const base = require('./nightwatch.conf.js');

module.exports = {
  ...base,
  src_folders: ['tests/e2e/screenshots'],
  test_settings: {
    ...base.test_settings,
    default: {
      ...base.test_settings.default,
      desiredCapabilities: {
        browserName: 'chrome',
        chromeOptions: {
          args: [
            'window-size=800,900',
            '--force-device-scale-factor=2',
          ]
        }
      }
    }
  }
};
