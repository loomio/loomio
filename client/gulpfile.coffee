gulp     = require 'gulp'
paths    = require './tasks/paths'
sequence = require 'gulp-run-sequence'

angular  = require './tasks/angular'
vue      = require './tasks/vue'
execjs   = require './tasks/execjs'
shared   = require './tasks/shared'

gulp.task 'angular:haml',          angular.haml
gulp.task 'angular:scss',          angular.scss
gulp.task 'angular:vendor',        angular.vendor
gulp.task 'shared:fonts',          shared.fonts
gulp.task 'shared:emoji',          shared.emoji
gulp.task 'shared:moment_locales', shared.moment_locales

gulp.task 'angular:external', ['angular:haml', 'angular:scss', 'angular:vendor', 'shared:fonts', 'shared:emoji', 'shared:moment_locales']

gulp.task 'angular:bundle:dev',     angular.development
gulp.task 'angular:bundle:prod',    angular.production

gulp.task 'execjs:bundle:dev',      execjs.development
gulp.task 'execjs:bundle:prod',     execjs.production

gulp.task 'vue:bundle:dev',         vue.development
gulp.task 'vue:bundle:prod',        vue.production

gulp.task 'bundle:dev',  ['angular:bundle:dev',  'execjs:bundle:dev',  'vue:bundle:dev']
gulp.task 'bundle:prod', ['angular:bundle:prod', 'execjs:bundle:prod', 'vue:bundle:prod']

gulp.task 'dev',         (done) -> sequence('angular:external', 'bundle:dev', 'watch', -> done())
gulp.task 'compile',     (done) -> sequence('angular:external', 'bundle:prod', -> done())

gulp.task 'watch',              require('./tasks/watch')
gulp.task 'protractor:core',    require('./tasks/protractor/core')
gulp.task 'protractor:plugins', require('./tasks/protractor/plugins')

gulp.task 'protractor',     (done) -> sequence('angular:bundle:dev', 'protractor:now', -> done())
gulp.task 'protractor:now', (done) -> sequence('protractor:core', 'protractor:plugins', -> done() )
