# writes dist/javascripts/app(.min).js
paths      = require './paths'
onError    = require './onerror'
gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
plumber    = require 'gulp-plumber'
coffee     = require 'gulp-coffee'
toCoffee   = require 'gulp-javascript-to-coffeescript'
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
buffer     = require 'vinyl-buffer'
coffeeify  = require 'coffeeify'
babelify   = require 'babelify'
source     = require 'vinyl-source-stream'
fs         = require 'fs'
collapse   = require 'bundle-collapser/plugin'
gutil      = require 'gulp-util'
_          = require 'lodash'
budo       = require 'budo'
uglify     = require('gulp-uglify/composer')(require('uglify-es', console))

module.exports =
  # development: ->
  #   requireForBundle()
  #   budo paths.angular.main,
  #     serve: "client/development/angular.bundle.js"
  #     stream: process.stdout
  #     live: true
  #     port: 4002
  #     browserify: browserifyOpts()
  #
  # production: ->
  #   requireForBundle()
  #   browserify(browserifyOpts())
  #     .transform("babelify", {presets: ["es2015", "@babel/preset-env"], extensions: ['.coffee', '.js']})
  #     .plugin(collapse)
  #     .transform('uglifyify')
  #     .bundle()
  #     .pipe(source('angular.bundle.min.js'))
  #     .pipe(buffer())
  #     .pipe(uglify())
  #     .on('error', onError)
  #     .pipe(gulp.dest(paths.dist.assets))

  # haml: ->
  #   pipe gulp.src(paths.angular.folders.templates), [
  #     plumber(errorHandler: onError),
  #     haml(),
  #     htmlmin(),
  #     template(
  #       module: 'loomioApp'
  #       transformUrl: (url) ->
  #         if url.match /.+\/.+/
  #           "generated/components/#{url}"
  #         else
  #           "generated/components/#{url.split('.')[0]}/#{url}"
  #     )
  #     toCoffee().on('error', gutil.log)
  #     concat("templates.coffee"),
  #     gulp.dest(paths.angular.dependencies.folder)
  #   ]

  scss: ->
    pipe gulp.src(paths.angular.scss), [
      plumber(errorHandler: onError),
      replace('screen\\0','screen'),
      concat("angular.css"),
      sass(includePaths: paths.angular.scss_include),
      gulp.dest(paths.dist.assets),
      prefix(browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Safari >= 9'], cascade: false),
      cssmin(),
      rename(suffix: '.min'),
      gulp.dest(paths.dist.assets)
    ]

requireForBundle = ->
  _.each ['vendor', 'config', 'pages', 'components'], (name) ->
    fs.writeFileSync paths.angular.dependencies[name], _.map(paths.angular.folders[name], (file) ->
      "require '#{file}'"
    ).join("\n")

browserifyOpts = ->
  entries: paths.angular.main
  paths: ['./', './node_modules']
  extensions: ['.coffee', '.js']
  transform: [coffeeify]
