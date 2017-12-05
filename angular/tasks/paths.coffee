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
  app:
    coffee:       _.flatten(['boot/**/*.coffee', 'core/**/*.coffee'])
    haml:         _.flatten(['core/components/**/*.haml'])
    scss:         _.flatten([include(vendor, 'css'), 'core/css/app.scss', 'core/components/**/*.scss'])
    scss_include: _.flatten([include(vendor, 'css_includes'), 'core/css'])

  plugin:
    coffee: include plugins, 'coffee'
    haml:   include plugins, 'haml'
    scss:   _.flatten(['core/css/plugin.scss', include(plugins, 'scss')])
    scss_include: ['core/css']

  extra:
    emojis:         include(vendor, 'emoji')
    moment_locales: include(vendor, 'moment_locales')
    fonts:          include(vendor, 'fonts')

  dist:
    fonts:          '../public/client/fonts'
    assets:         '../public/client/development'
    emojis:         '../public/img/emojis'
    moment_locales: '../public/client/development/moment_locales'

  js:
    execcoffee:   'core/initializers/**/*.coffee'
    execjs:       _.flatten(include(vendor, 'execjs'), include(vendor, 'lodash'))
    vendor:       include(vendor, 'js')

  protractor:
    config:       'test/protractor.coffee'
    screenshots:  'test/protractor/screenshots'
    specs:
      core:        'test/protractor/*_spec.coffee'
      plugins:     ['../plugins/**/*_spec.coffee', 'test/protractor/testing_spec.coffee']
