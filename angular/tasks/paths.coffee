config = require('node-yaml-config').reload('config.yml')
_      = require 'lodash'
include = (key, file) -> _.map(config.vendor[key], (file) -> [config.vendor.path, file].join('/'))

module.exports = {
  css: {
    core:           _.flatten([include('css'), 'core/css/main.scss', 'core/components/**/*.scss']),
    includes:       _.flatten([include('css_includes'), 'core/css'])
  },
  dist: {
    fonts:  '../public/fonts',
    assets: '../public/assets',
  },
  fonts: {
    vendor:         include('fonts')
  },
  html: {
    core:           'core/components/**/*.haml'
  },
  js: {
    core:           'core/**/*.coffee',
    vendor:         include('js')
  }
  protractor: {
    config:      'test/protractor.coffee',
    screenshots: 'test/protractor/screenshots',
    specs:       'test/protractor/*_spec.coffee'
  }
}
