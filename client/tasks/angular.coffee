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
uglify     = require 'gulp-uglify'
prefix     = require 'gulp-autoprefixer'
cssmin     = require 'gulp-cssmin'
browserify = require 'browserify'
coffeeify  = require 'coffeeify'
annotate   = require 'browserify-ngannotate' # to allow for minification of angular
glob       = require 'globby'
source     = require 'vinyl-source-stream'
fs         = require 'fs'
gutil      = require 'gulp-util'
_          = require 'lodash'

module.exports =
  bundle:
    development: ->
      browserify(entries: paths.core.main, paths: ['./', './node_modules'])
        .transform(coffeeify)
        .transform(babelify, presets: ['es2105'])
        .bundle()
        .pipe(source('angular.bundle.min.js'))
        .pipe(buffer())
        .on('error', (err) -> gutil.log(gutil.colors.red('[Error]'), err.toString()))
        .pipe(gulp.dest(paths.dist.assets))

    production: ->
      browserify(entries: paths.core.main, paths: ['./', './node_modules'])
        .transform(coffeeify)
        .transform(babelify, presets: ['es2105'])
        .transform(annotate)
        .transform(uglifyify, global: true)
        .external('angular')
        .bundle()
        .pipe(source('angular.bundle.min.js'))
        .pipe(buffer())
        .on('error', (err) -> gutil.log(gutil.colors.red('[Error]'), err.toString()))
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

minifyJs = (filenames...) ->
  _.each filenames, (filename) ->
    pipe gulp.src("#{paths.dist.assets}/#{filename}.js"), [
      uglify(mangle: false),
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
