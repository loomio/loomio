# writes dist/javascripts/app(.min).js
paths    = require './paths'
onError  = require './onerror'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
plumber  = require 'gulp-plumber'
coffee   = require 'gulp-coffee'
append   = require 'add-stream'
haml     = require 'gulp-haml'
htmlmin  = require 'gulp-htmlmin'
template = require 'gulp-angular-templatecache'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'

module.exports = ->
  pipe gulp.src(paths.core.coffee), [
    plumber(errorHandler: onError),             # handle errors gracefully
    coffee(bare: true),                         # convert from coffeescript to js
    append.obj(pipe gulp.src(paths.core.haml), [  # build html template cache
      haml(),                                     # convert haml to html
      htmlmin(),                                  # minify html
      template(                                   # store html templates in angular cache
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
    uglify(),                                   # minify app.js file
    rename(suffix: '.min'),                     # rename stream to app.min.js
    gulp.dest(paths.dist.assets)                # write assets/app.min.js
  ]
