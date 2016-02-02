config = require('node-yaml-config').reload('config.yml')
_      = require 'lodash'
include = (key, file) -> _.map(config.vendor[key], (file) -> ['.', config.vendor.path, file].join('/'))

module.exports = {
  css: {
    core:           _.flatten([include('css'), 'core/css/main.scss', 'core/components/**/*.scss']),
    includes:       _.flatten([include('css_includes'), 'core/css'])
  },
  dist: {
    all:            'dist/**/*.*',
    fonts:          'dist/fonts',
    javascripts:    'dist/javascripts',
    stylesheets:    'dist/stylesheets'
  },
  fonts: {
    vendor:         include('fonts')
  },
  html: {
    core:           'core/components/**/*.haml'
  },
  img: {
    core:           'core/img/*.{png,gif,jpg,jpeg}'
  },
  js: {
    core:           'core/**/*.coffee',
    vendor:         include('js')
  }
  public:           '../public',
  protractor: {
    config:      'test/protractor.coffee',
    screenshots: 'test/protractor/screenshots',
    specs:       'test/protractor/*_spec.coffee'
  }
}
