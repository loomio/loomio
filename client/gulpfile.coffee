gulp     = require 'gulp'
paths    = require './tasks/paths'
sequence = require 'gulp-run-sequence'

angular = require './tasks/angular'
e2e     = require './tasks/e2e'
execjs  = require './tasks/execjs'
shared  = require './tasks/shared'

gulp.task 'angular:haml',          angular.haml
gulp.task 'angular:scss',          angular.scss
gulp.task 'shared:moment_locales', shared.moment_locales

gulp.task 'angular:external', ['angular:haml', 'angular:scss', 'shared:moment_locales']

gulp.task 'angular:bundle:dev',     angular.development
gulp.task 'angular:bundle:prod',    angular.production

gulp.task 'execjs:bundle:dev',      execjs.development
gulp.task 'execjs:bundle:prod',     execjs.production

gulp.task 'bundle:dev',  ['angular:bundle:dev',  'execjs:bundle:dev']
gulp.task 'bundle:prod', ['angular:bundle:prod', 'execjs:bundle:prod']

gulp.task 'dev',         (done) -> sequence('angular:external', 'bundle:dev', 'watch', -> done())
gulp.task 'compile',     (done) -> sequence('angular:external', 'bundle:prod', -> done())

gulp.task 'watch', require('./tasks/watch')

gulp.task 'nightwatch:core',        e2e.nightwatch.core
gulp.task 'nightwatch:plugins',     e2e.nightwatch.plugins
