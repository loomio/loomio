# writes dist/javascripts/app(.min).js
paths      = require './paths'
onError    = require './onerror'
gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
plumber    = require 'gulp-plumber'
coffee     = require 'gulp-coffee'
append     = require 'add-stream'
sass       = require 'gulp-sass'
haml       = require 'gulp-haml'
replace    = require 'gulp-replace'
htmlmin    = require 'gulp-htmlmin'
template   = require 'gulp-angular-templatecache'
concat     = require 'gulp-concat'
rename     = require 'gulp-rename'
expect     = require 'gulp-expect-file'
prefix     = require 'gulp-autoprefixer'
cssmin     = require 'gulp-cssmin'
browserify = require 'browserify'
babelify   = require 'babelify'
buffer     = require 'vinyl-buffer'
coffeeify  = require 'coffeeify'
glob       = require 'globby'
source     = require 'vinyl-source-stream'
fs         = require 'fs'
gutil      = require 'gulp-util'
_          = require 'lodash'
budo       = require 'budo'
uglify     = require('gulp-uglify/composer')(require('uglify-es', console))

module.exports =
  bundle:
    development: ->
      requireForBundle()
      budo paths.core.main,
        serve: "client/development/angular.bundle.js"
        stream: process.stdout
        live: true
        port: 4002
        browserify: browserifyOpts()

    production: ->
      requireForBundle()
      browserify(browserifyOpts())
        .transform('uglifyify', global: true)
        .bundle()
        .pipe(source('angular.bundle.min.js'))
        .pipe(buffer())
        .pipe(gulp.dest(paths.dist.assets))
        .pipe(uglify())
        .on('error', onError)
        .pipe(gulp.dest(paths.dist.assets))

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

  minify:
    js:     -> minifyJs     'angular.vendor', 'execjs'
    css:    -> minifyCss    'angular.core', 'angular.plugin'

requireForBundle = ->
  core    = _.flatten _.map paths.core.folders, (folder) -> _.map glob.sync("angular/#{folder}/**/*.coffee")
  plugins = _.map paths.plugin.coffee, (file) -> "../#{file}"

  fs.writeFile paths.core.main,  _.map(core, (file) -> "require '#{file}'").join("\n")
  fs.appendFile(paths.core.main, "\n")
  fs.appendFile paths.core.main, _.map(plugins, (file) -> "require '#{file}'").join("\n")

browserifyOpts = ->
  entries: paths.core.main,
  paths: ['./', './node_modules']
  transform: [coffeeify]

buildHaml = (prefix) ->
  pipe gulp.src(paths[prefix].haml), [
    plumber(errorHandler: onError),
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

minifyJs = (filenames...) ->
  _.each filenames, (filename) ->
    pipe gulp.src("#{paths.dist.assets}/#{filename}.js"), [
      plumber(errorHandler: onError),
      uglify(),
      rename(suffix: '.min'),
      gulp.dest(paths.dist.assets)
    ]

minifyCss = (filenames...) ->
  _.each filenames, (filename) ->
    pipe gulp.src("#{paths.dist.assets}/#{filename}.css"), [
      plumber(errorHandler: onError),
      prefix(browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Safari >= 9'], cascade: false),
      cssmin(),
      rename(suffix: '.min'),
      gulp.dest(paths.dist.assets)
    ]
