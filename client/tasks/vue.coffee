gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
browserify = require 'browserify'
buffer     = require 'vinyl-buffer'
vueify     = require 'vueify'
coffeeify  = require 'coffeeify'
babelify   = require 'babelify'
uglify     = require('gulp-uglify/composer')(require('uglify-es', console))
source     = require 'vinyl-source-stream'
rename     = require 'gulp-rename'
cssmin     = require 'gulp-cssmin'
prefix     = require 'gulp-autoprefixer'
paths      = require './paths'
gutil      = require 'gulp-util'
budo       = require 'budo'
onError    = require './onerror'

module.exports =
  bundle:
    development: ->
      budo paths.vue.main,
        serve: "client/development/vue.bundle.js"
        stream: process.stdout
        live: true
        port: 4001
        browserify: browserifyOpts()

    production: ->
      browserify(browserifyOpts())
        .plugin('vueify-extract-css', out: "#{paths.dist.assets}/vue.bundle.css")
        .external('vue')
        .bundle()
        .pipe(source('vue.bundle.min.js'))
        .pipe(buffer())
        .on('error', onError)
        .pipe(uglify())
        .pipe(gulp.dest(paths.dist.assets))
      pipe gulp.src("#{paths.dist.assets}/vue.bundle.css"), [
        prefix(browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Safari >= 9'], cascade: false),
        cssmin(),
        rename(suffix: '.min'),
        gulp.dest(paths.dist.assets)
      ]

browserifyOpts = ->
  entries: paths.vue.main
  paths: ['./', './node_modules']
  transform: [coffeeify, vueify]
