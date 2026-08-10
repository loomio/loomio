const chromeArgs = ['window-size=1280,6400'];

if (process.env.NIGHTWATCH_DEVICE_SCALE_FACTOR) {
  chromeArgs.push(`--force-device-scale-factor=${process.env.NIGHTWATCH_DEVICE_SCALE_FACTOR}`);
}

module.exports = {
  detailed_output: false,
  skip_testcases_on_fail: false,
  src_folders: [process.env.NIGHTWATCH_SRC_FOLDERS || 'tests/e2e/specs'],
  output_folder: 'tests/reports',
  plugins: [],
  globals_path: '',
  webdriver: {},

  test_settings: {
    default: {
      "silent": true,
      disable_error_log: false,
      launch_url: 'http://localhost:8080',

      screenshots: {
        enabled: true,
        path: './tests/screenshots',
        on_failure: true,
        on_error: true
      },

      desiredCapabilities: {
        browserName: 'chrome',
        chromeOptions: {
          args: chromeArgs
        }
      },
      
      webdriver: {
        start_process: true,
        server_path: ''
      },
    },
  },
  
};
