gulp     = require 'gulp'
paths    = require './tasks/paths'
sequence = require 'gulp-run-sequence'

vendor   = require './tasks/vendor'
execjs   = require './tasks/execjs'
app      = require './tasks/app'
plugin   = require './tasks/plugin'
minify   = require './tasks/minify'
extra    = require './tasks/extra'
vue      = require './tasks/vue'

gulp.task 'angular:vendor',          vendor
gulp.task 'angular:execjs',          execjs
gulp.task 'angular:require',         app.require
gulp.task 'angular:browserify',      app.browserify
gulp.task 'angular:bundle',          (done) -> sequence('angular:require', 'angular:browserify', -> done())
gulp.task 'angular:app_haml',        app.haml
gulp.task 'angular:app_scss',        app.scss
gulp.task 'angular:plugin_haml',     plugin.haml
gulp.task 'angular:plugin_scss',     plugin.scss
gulp.task 'angular:fonts',           extra.fonts
gulp.task 'angular:emoji',           extra.emoji
gulp.task 'angular:moment_locales',  extra.moment_locales
gulp.task 'angular:minify-js',       minify.app.js
gulp.task 'angular:minify-css',      minify.app.css
gulp.task 'angular:minify-bundle',   minify.app.bundle
gulp.task 'angular:minify', ['angular:minify-js', 'angular:minify-bundle', 'angular:minify-css']
gulp.task 'angular:compile-fast', [
  'angular:fonts',
  'angular:bundle',
  'angular:app_haml',
  'angular:app_scss',
  'angular:plugin_haml',
  'angular:plugin_scss',
  'angular:vendor',
  'angular:emoji',
  'angular:execjs',
  'angular:moment_locales'
]

gulp.task 'vue:bundle',               vue.browserify
gulp.task 'vue:minify-js',            minify.vue.js
gulp.task 'vue:minify-css',           minify.vue.css
gulp.task 'vue:minify', ['vue:minify-js', 'vue:minify-css']
gulp.task 'vue:compile-fast', ['vue:bundle']

gulp.task 'compile-fast', ['angular:compile-fast', 'vue:compile-fast']
gulp.task 'minify', ['vue:minify', 'angular-minify']
gulp.task 'compile', (done) -> sequence('compile-fast', 'minify', -> done())
gulp.task 'dev',            -> sequence('compile-fast', require('./tasks/watch'))

gulp.task 'protractor:core',    require('./tasks/protractor/core')
gulp.task 'protractor:plugins', require('./tasks/protractor/plugins')

gulp.task 'protractor',     -> sequence('compile-fast', 'protractor:now')
gulp.task 'protractor:now', -> sequence('protractor:core', 'protractor:plugins')
