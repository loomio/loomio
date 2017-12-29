gulp     = require 'gulp'
paths    = require './tasks/paths'
sequence = require 'gulp-run-sequence'

angular  = require './tasks/angular'
vue      = require './tasks/vue'
execjs   = require './tasks/execjs'
extra    = require './tasks/extra'
watch    = require './tasks/watch'

gulp.task 'angular:vendor',          angular.vendor
gulp.task 'angular:core:haml',       angular.core.haml
gulp.task 'angular:core:scss',       angular.core.scss
gulp.task 'angular:plugin:haml',     angular.plugin.haml
gulp.task 'angular:plugin:scss',     angular.plugin.scss
gulp.task 'angular:minify:js',       angular.minify.js
gulp.task 'angular:minify:css',      angular.minify.css
gulp.task 'angular:bundle:dev',      angular.bundle.development
gulp.task 'angular:bundle:prod',     angular.bundle.production

gulp.task 'angular:fonts',           extra.fonts
gulp.task 'angular:emoji',           extra.emoji
gulp.task 'angular:moment_locales',  extra.moment_locales

gulp.task 'execjs:bundle:dev',       execjs.development
gulp.task 'execjs:bundle:prod',      execjs.production

gulp.task 'angular:external:extra', [
  'angular:fonts',
  'angular:vendor',
  'angular:emoji',
  'angular:moment_locales'
]
gulp.task 'angular:external:dev', [
  'angular:core:haml',
  'angular:core:scss',
  'angular:plugin:haml',
  'angular:plugin:scss'
]
gulp.task 'angular:external', ['angular:external:extra', 'angular:external:dev']
gulp.task 'angular:external:prod', (done) -> sequence('angular:external', ['angular:minify:js', 'angular:minify:css'], -> done())

gulp.task 'vue:bundle:dev',  vue.bundle.development
gulp.task 'vue:bundle:prod', vue.bundle.production

gulp.task 'bundle:dev',  ['angular:external', 'angular:bundle:dev', 'vue:bundle:dev', 'execjs:bundle:dev']

gulp.task 'watch',       watch
gulp.task 'dev',         (done) -> sequence('bundle:dev', 'watch', -> done())
gulp.task 'compile',     ['angular:external:prod', 'angular:bundle:prod', 'execjs:bundle:prod', 'vue:bundle:prod']

gulp.task 'protractor:core',    require('./tasks/protractor/core')
gulp.task 'protractor:plugins', require('./tasks/protractor/plugins')

gulp.task 'protractor',     (done) -> sequence('angular:bundle:dev', 'protractor:now', -> done())
gulp.task 'protractor:now', (done) -> sequence('protractor:core', 'protractor:plugins', -> done() )
