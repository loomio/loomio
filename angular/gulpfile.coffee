gulp     = require 'gulp'
paths    = require './tasks/paths'
sequence = require 'gulp-run-sequence'

gulp.task 'fonts',  require('./tasks/fonts')
gulp.task 'app',    require('./tasks/app')
gulp.task 'vendor', require('./tasks/vendor')
gulp.task 'scss',   require('./tasks/scss')
gulp.task 'execjs', require('./tasks/execjs')
gulp.task 'minify-app', require('./tasks/minify_app')
gulp.task 'minify-css', require('./tasks/minify_css')
gulp.task 'minify', ['minify-app', 'minify-css']

gulp.task 'compile-minify', (done) -> sequence('compile', 'minify', -> done())
gulp.task 'compile', ['fonts', 'app','vendor','scss', 'execjs']

gulp.task 'dev', -> sequence('compile', require('./tasks/watch'))

gulp.task 'protractor:core', require('./tasks/protractor/core')
gulp.task 'protractor:plugins', require('./tasks/protractor/plugins')

gulp.task 'protractor', -> sequence('compile', 'protractor:now')
gulp.task 'protractor:now', -> sequence('protractor:core', 'protractor:plugins')
