module.exports = {
  detailed_output: false,
  skip_testcases_on_fail: false,
  src_folders: ['tests/e2e/specs'],
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
          args: ['window-size=1280,6400']
        }
      },
      
      webdriver: {
        start_process: true,
        server_path: ''
      },
    },
  },
  
};
