gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
browserify = require 'browserify'
buffer     = require 'vinyl-buffer'
vueify     = require 'vueify'
coffeeify  = require 'coffeeify'
babelify   = require 'babelify'
uglifyify  = require 'uglifyify'
source     = require 'vinyl-source-stream'
rename     = require 'gulp-rename'
cssmin     = require 'gulp-cssmin'
prefix     = require 'gulp-autoprefixer'
paths      = require './paths'
gutil      = require 'gulp-util'

module.exports =
  bundle:
    development: ->
      browserify(entries: paths.vue.main, paths: ['./', './node_modules'])
        .transform(coffeeify)
        .transform(vueify)
        .plugin('vueify-extract-css', out: "#{paths.dist.assets}/vue.bundle.css")
        .transform(babelify, presets: ['es2015'])
        .external('vue')
        .bundle()
        .pipe(source('vue.bundle.js'))
        .pipe(gulp.dest(paths.dist.assets))

    production: ->
      browserify(entries: paths.vue.main, paths: ['./', './node_module'])
        .transform(coffeeify)
        .transform(vueify)
        .plugin('vueify-extract-css', out: "#{paths.dist.assets}/vue.bundle.css")
        .transform(babelify, presets: ['es2105'])
        .transform(uglifyify, global: true)
        .external('vue')
        .bundle()
        .pipe(source('vue.bundle.min.js'))
        .pipe(buffer())
        .on('error', (err) -> gutil.log(gutil.colors.red('[Error]'), err.toString()))
        .pipe(gulp.dest(paths.dist.assets))
      pipe gulp.src("#{paths.dist.assets}/vue.bundle.css"), [
        prefix(browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Safari >= 9'], cascade: false),
        cssmin(),
        rename(suffix: '.min'),
        gulp.dest(paths.dist.assets)
      ]
