yaml    = require('node-yaml-config')
vendor  = yaml.reload('tasks/config/vendor.yml')
glob    = require 'globby'
_       = require 'lodash'

plugins = try
  yaml.reload('tasks/config/plugins.yml')
catch
  {}

include = (file, key, p = file.path) ->
  _.map(file[key], (path) -> _.compact([p, path]).join('/'))

module.exports =
  angular:
    root:      'angular'
    main:      'angular/main.coffee'
    folders:
      vendor:     include(vendor, 'angular', '')
      config:     glob.sync('angular/config/*.coffee')
      pages:      glob.sync('angular/pages/**/*.coffee')
      components: _.flatten([
        glob.sync('angular/components/**/*.coffee'),
        _.map(include(plugins, 'coffee'), (path) -> "../../#{path}")
      ])
      templates:   _.flatten([
        'angular/components/**/*.haml',
        'angular/pages/**/*.haml',
        include(plugins, 'haml')
      ])
    dependencies:
      folder:     'angular/dependencies'
      vendor:     'angular/dependencies/vendor.coffee'
      config:     'angular/dependencies/config.coffee'
      pages:      'angular/dependencies/pages.coffee'
      components: 'angular/dependencies/components.coffee'
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
    moment_locales: include(vendor, 'moment_locales')

  execjs:
    main:           'execjs/main.coffee'

  worker:
    main:           'worker/main.coffee'
    coffee:         'worker/*.coffee'

  dist:
    root:           '../public/'
    assets:         '../public/client/development'
    moment_locales: '../public/client/development/moment_locales'

  nightwatch:
    config:
      core:        'angular/test/nightwatch.core.json'
      plugins:     'angular/test/nightwatch.plugins.json'
