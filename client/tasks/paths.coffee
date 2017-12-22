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
    main:         './angular/main.coffee'
    folders:     ['initializers', 'config', 'filters', 'mixins', 'models', 'services', 'components']
    haml:         './angular/components/**/*.haml'
    scss:         _.flatten([include(vendor, 'css'), 'angular/css/app.scss', 'angular/components/**/*.scss'])
    scss_include: _.flatten([include(vendor, 'css_includes'), 'angular/css'])

  plugin:
    coffee: include plugins, 'coffee'
    haml:   include plugins, 'haml'
    scss:   _.flatten(['angular/css/plugin.scss', include(plugins, 'scss')])
    scss_include: './angular/css'

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
    execcoffee:   './angular/initializers/**/*.coffee'
    execjs:       _.flatten(include(vendor, 'execjs'), include(vendor, 'lodash'))
    vendor:       include(vendor, 'js')

  vue:
    coffee:         './vue/main.coffee'
    vue:            './vue/components/*.vue'

  protractor:
    config:       'angular/test/protractor.coffee'
    screenshots:  'angular/test/protractor/screenshots'
    specs:
      core:        'angular/test/protractor/*_spec.coffee'
      plugins:     ['../plugins/**/*_spec.coffee', 'angular/test/protractor/testing_spec.coffee']
