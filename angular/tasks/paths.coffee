yaml    = require('node-yaml-config')
vendor  = yaml.reload('tasks/config/vendor.yml')
_       = require 'lodash'

plugins = try
  yaml.reload('tasks/config/plugins.yml')
catch
  {}

include = (file, key) ->
  _.map(file[key], (path) -> [file.path, path].join('/'))

module.exports =
  core:
    coffee:       _.flatten(['core/**/*.coffee', include(plugins, 'coffee')])
    haml:         _.flatten(['core/components/**/*.haml', include(plugins, 'haml')])
    scss:         _.flatten([include(vendor, 'css'), 'core/css/main.scss', 'core/components/**/*.scss', include(plugins, 'scss')])
    print:        _.flatten([include(vendor, 'css'), 'core/css/main.scss', 'core/components/**/*.scss', include(plugins, 'scss'), 'core/css/print/**/*.scss'])
    scss_include: _.flatten([include(vendor, 'css_includes'), 'core/css'])
  dist:
    fonts:        '../public/client/fonts'
    assets:       '../public/client/development'
  fonts:
    vendor:       include(vendor, 'fonts')
  html:
    core:         'core/components/**/*.haml'
  js:
    core:         'core/**/*.coffee',
    execjs:       _.flatten([include(vendor, 'execjs'), 'core/initializers/**/*.coffee'])
    vendor:       include(vendor, 'js')
  protractor:
    config:       'test/protractor.coffee'
    screenshots:  'test/protractor/screenshots'
    specs:        'test/protractor/*_spec.coffee'
