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
  angular:
    root:      'angular'
    main:      'angular/main.coffee'
    templates: 'angular/templates.coffee'
    vendor:    include(vendor, 'angular')
    plugin:    include plugins, 'coffee'
    folders:   ['initializers', 'config', 'pages', 'components']
    haml: _.flatten([
      'angular/components/**/*.haml',
      'angular/pages/**/*.haml',
      include(plugins, 'haml')
    ])
    scss: _.flatten([
      include(vendor, 'css'),
      'angular/css/app.scss',
      'angular/components/**/*.scss',
      'angular/pages/**/*.scss',
      include(plugins, 'scss')
    ])
    scss_include: _.flatten([
      include(vendor, 'css_includes'),
      'angular/css'
    ])

  shared:
    coffee:       'shared/**/*.coffee'
    emojis:         include(vendor, 'emoji')
    moment_locales: include(vendor, 'moment_locales')
    fonts:          include(vendor, 'fonts')

  execjs:
    main:           'execjs/main.coffee'

  dist:
    fonts:          '../public/client/fonts'
    assets:         '../public/client/development'
    emojis:         '../public/img/emojis'
    moment_locales: '../public/client/development/moment_locales'

  js:
    execcoffee:   'angular/initializers/**/*.coffee'
    vendor:       include(vendor, 'js')

  vue:
    main:           'vue/main.coffee'
    vue:            'vue/components/*.vue'

  protractor:
    config:       'angular/test/protractor.coffee'
    screenshots:  'angular/test/protractor/screenshots'
    specs:
      core:        'angular/test/protractor/*_spec.coffee'
      plugins:     ['../plugins/**/*_spec.coffee', 'angular/test/protractor/testing_spec.coffee']
