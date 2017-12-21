# writes dist/javascripts/app(.min).js
paths    = require './paths'
onError  = require './onerror'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
plumber  = require 'gulp-plumber'
coffee   = require 'gulp-coffee'
append   = require 'add-stream'
sass     = require 'gulp-sass'
haml     = require 'gulp-haml'
replace  = require 'gulp-replace'
htmlmin  = require 'gulp-htmlmin'
template = require 'gulp-angular-templatecache'
concat   = require 'gulp-concat'
rename   = require 'gulp-rename'

browserify = require 'browserify'
source     = require 'vinyl-source-stream'


module.exports =
  coffee: ->
    pipe gulp.src(paths.app.coffee), [
      plumber(errorHandler: onError),              # handle errors gracefully
      coffee(bare: true),                          # convert from coffeescript to js
      append.obj(pipe gulp.src(paths.app.haml), [  # build html template cache
        haml(),                                    # convert haml to html
        htmlmin(),                                 # minify html
        template(                                  # store html templates in angular cache
          module: 'loomioApp',
          transformUrl: (url) ->
            if url.match /.+\/.+/
              "generated/components/#{url}"
            else
              "generated/components/#{url.split('.')[0]}/#{url}"
        ),
      ]),
      concat('app.js'),                           # concatenate app files
      gulp.dest(paths.dist.assets)                # write assets/app.js
    ]
    browserify(entries: ["#{paths.dist.assets}/app.js"], paths: ['./node_modules', './'])
      .bundle()
      .pipe(source('app.bundle.js'))
      .pipe(gulp.dest(paths.dist.assets))

  scss: ->
    pipe gulp.src(paths.app.scss), [
      plumber(errorHandler: onError),                # handle errors gracefully
      replace('screen\\0','screen'),                 # workaround for https://github.com/angular/material/issues/6304
      concat('app.css'),                             # concatenate scss files
      sass(includePaths: paths.app.scss_include),    # convert scss to css (include vendor path for @imports)
      gulp.dest(paths.dist.assets)                   # write assets/app.min.css
    ]
