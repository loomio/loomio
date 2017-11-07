gulp     = require 'gulp'
paths    = require './tasks/paths'
sequence = require 'gulp-run-sequence'

gulp.task 'fonts',  require('./tasks/fonts')
gulp.task 'app',    require('./tasks/app')
gulp.task 'vendor', require('./tasks/vendor')
gulp.task 'emoji',  require('./tasks/emoji')
gulp.task 'moment_locales',  require('./tasks/moment_locales')
gulp.task 'scss',   require('./tasks/scss')
gulp.task 'execjs', require('./tasks/execjs')
gulp.task 'minify-js', require('./tasks/minify_js')
gulp.task 'minify-css', require('./tasks/minify_css')
gulp.task 'minify', ['minify-js', 'minify-css']

gulp.task 'compile', (done) -> sequence('compile-fast', 'minify', -> done())
gulp.task 'compile-fast', ['fonts','app','vendor','emoji','scss','execjs', 'moment_locales']

gulp.task 'dev', -> sequence('compile-fast', require('./tasks/watch'))

gulp.task 'protractor:core', require('./tasks/protractor/core')
gulp.task 'protractor:plugins', require('./tasks/protractor/plugins')

gulp.task 'protractor', -> sequence('compile', 'protractor:now')
gulp.task 'protractor:now', -> sequence('protractor:core', 'protractor:plugins')
