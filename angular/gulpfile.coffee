gulp     = require 'gulp'
paths    = require './tasks/paths'
sequence = require 'gulp-run-sequence'

gulp.task 'fonts',  require('./tasks/fonts')
gulp.task 'app',    require('./tasks/app')
gulp.task 'vendor', require('./tasks/vendor')
gulp.task 'scss',   require('./tasks/scss')

gulp.task 'compile', ['fonts', 'app','vendor','scss']

gulp.task 'dev', -> sequence('compile', require('./tasks/watch'))

gulp.task 'protractor:now', require('./tasks/protractor')
gulp.task 'protractor', -> sequence('compile', 'protractor:now')
