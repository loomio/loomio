# writes dist/javascripts/app(.min).js
paths    = require './paths'
onError  = require './onerror'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
plumber  = require 'gulp-plumber'
coffee   = require 'gulp-coffee'
append   = require 'add-stream'
sass     = require 'gulp-sass'
haml     = require 'gulp-haml'
replace  = require 'gulp-replace'
htmlmin  = require 'gulp-htmlmin'
template = require 'gulp-angular-templatecache'
concat   = require 'gulp-concat'
rename   = require 'gulp-rename'
expect   = require 'gulp-expect-file'

browserify = require 'browserify'
coffeeify  = require 'coffeeify'
annotate   = require 'browserify-ngannotate' # to allow for minification of angular
glob       = require 'globby'
source     = require 'vinyl-source-stream'
fs         = require 'fs'
_          = require 'lodash'
gutil      = require 'gulp-util'

module.exports =
  require: ->
    core    = _.flatten _.map paths.core.folders, (folder) -> _.map glob.sync("angular/#{folder}/**/*.coffee")
    plugins = _.map paths.plugin.coffee, (file) -> "../#{file}"

    fs.writeFile paths.core.main,  _.map(core, (file) -> "require '#{file}'").join("\n")
    fs.appendFile(paths.core.main, "\n")
    fs.appendFile paths.core.main, _.map(plugins, (file) -> "require '#{file}'").join("\n")

  browserify: ->
    pipe browserify(
      entries: [paths.core.main]
      transform: [coffeeify, annotate]
      paths: ['./', './node_modules']
    ).bundle().on('error', (err) -> console.log(err)), [
      source('angular.bundle.js'),
      gulp.dest(paths.dist.assets)
    ]

  vendor: ->
    pipe gulp.src(paths.js.vendor), [
      expect({errorOnFailure: true}, paths.js.vendor),
      concat('angular.vendor.js'),
      gulp.dest(paths.dist.assets)
    ]

  core:
    haml: -> buildHaml('core')
    scss: -> buildScss('core')
  plugin:
    haml: -> buildHaml('plugin')
    scss: -> buildScss('plugin')

buildHaml = (prefix) ->
  pipe gulp.src(paths[prefix].haml), [
    haml(),
    htmlmin(),
    template(
      module: 'loomioApp',
      transformUrl: (url) ->
        if url.match /.+\/.+/
          "generated/components/#{url}"
        else
          "generated/components/#{url.split('.')[0]}/#{url}"
    )
    concat("angular.#{prefix}-templates.js")
    gulp.dest(paths.dist.assets)
  ]

buildScss = (prefix) ->
  pipe gulp.src(paths[prefix].scss), [
    plumber(errorHandler: onError),
    replace('screen\\0','screen'),
    concat("angular.#{prefix}.css"),
    sass(includePaths: paths[prefix].scss_include),
    gulp.dest(paths.dist.assets)
  ]
