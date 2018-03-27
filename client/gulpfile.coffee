gulp     = require 'gulp'
paths    = require './tasks/paths'
sequence = require 'gulp-run-sequence'

angular = require './tasks/angular'
e2e     = require './tasks/e2e'
vue     = require './tasks/vue'
execjs  = require './tasks/execjs'
worker  = require './tasks/worker'
shared  = require './tasks/shared'

gulp.task 'angular:haml',          angular.haml
gulp.task 'angular:scss',          angular.scss
gulp.task 'shared:fonts',          shared.fonts
gulp.task 'shared:emoji',          shared.emoji
gulp.task 'shared:moment_locales', shared.moment_locales

gulp.task 'angular:external', ['angular:haml', 'angular:scss', 'shared:fonts', 'shared:emoji', 'shared:moment_locales']

gulp.task 'angular:bundle:dev',     angular.development
gulp.task 'angular:bundle:prod',    angular.production

gulp.task 'execjs:bundle:dev',      execjs.development
gulp.task 'execjs:bundle:prod',     execjs.production

gulp.task 'worker:bundle:dev',      worker.development
gulp.task 'worker:bundle:prod',     worker.production

gulp.task 'vue:bundle:dev',         vue.development
gulp.task 'vue:bundle:prod',        vue.production

gulp.task 'bundle:dev',  ['angular:bundle:dev',  'execjs:bundle:dev',  'vue:bundle:dev', 'worker:bundle:dev']
gulp.task 'bundle:prod', ['angular:bundle:prod', 'execjs:bundle:prod', 'vue:bundle:prod', 'worker:bundle:prod']

gulp.task 'dev',         (done) -> sequence('angular:external', 'bundle:dev', 'watch', -> done())
gulp.task 'compile',     (done) -> sequence('angular:external', 'bundle:prod', -> done())

gulp.task 'watch', require('./tasks/watch')

gulp.task 'nightwatch:core',        e2e.nightwatch.core
gulp.task 'nightwatch:plugins',     e2e.nightwatch.plugins
