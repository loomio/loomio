gulp       = require 'gulp'
browserify = require 'browserify'
vueify     = require 'vueify'
uglify     = require 'gulp-uglify'
sequence   = require 'gulp-run-sequence'

distRoot = (path) ->
  "../public/client/webviews/#{path}"

appRoot = (path) ->
  "./core/components/#{path}"

gulp.task 'compile-fast', ->
  browserify(entries: ['./core/main.coffee'])
    .transform(vueify)
    .pipe(gulp.dest(distRoot('app.js')))

gulp.task 'minify', ->
  pipe gulp.src('./dist/app.js'), [
    uglify(),
    gulp.dest(distRoot('app.min.js'))
  ]

gulp.task 'watch', ->
  gulp.watch appRoot("**/*.vue"), ['compile-fast']

gulp.task 'compile', (done) -> sequence('compile-fast', 'minify', -> done())
gulp.task 'dev',            -> sequence('compile-fast', 'watch')
