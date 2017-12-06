gulp     = require 'gulp'
paths    = require './tasks/paths'
sequence = require 'gulp-run-sequence'

vendor   = require './tasks/vendor'
execjs   = require './tasks/execjs'
app      = require './tasks/app'
plugin   = require './tasks/plugin'
minify   = require './tasks/minify'
extra    = require './tasks/extra'

gulp.task 'vendor',          vendor
gulp.task 'execjs',          execjs
gulp.task 'app_coffee',      app.coffee
gulp.task 'app_scss',        app.scss
gulp.task 'plugin_coffee',   plugin.coffee
gulp.task 'plugin_scss',     plugin.scss
gulp.task 'fonts',           extra.fonts
gulp.task 'emoji',           extra.emoji
gulp.task 'moment_locales',  extra.moment_locales
gulp.task 'minify-js',       minify.js
gulp.task 'minify-css',      minify.css
gulp.task 'minify', ['minify-js', 'minify-css']

gulp.task 'compile', (done) -> sequence('compile-fast', 'minify', -> done())
gulp.task 'compile-fast', [
  'fonts',
  'app_coffee',
  'app_scss',
  'plugin_coffee',
  'plugin_scss',
  'vendor',
  'emoji',
  'execjs',
  'moment_locales'
]

gulp.task 'dev', -> sequence('compile-fast', require('./tasks/watch'))

gulp.task 'protractor:core', require('./tasks/protractor/core')
gulp.task 'protractor:plugins', require('./tasks/protractor/plugins')

gulp.task 'protractor', -> sequence('compile', 'protractor:now')
gulp.task 'protractor:now', -> sequence('protractor:core', 'protractor:plugins')
