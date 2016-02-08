# writes dist/javascripts/app(.min).js
paths    = require './paths'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
coffee   = require 'gulp-coffee'
append   = require 'add-stream'
haml     = require 'gulp-haml'
htmlmin  = require 'gulp-htmlmin'
template = require 'gulp-angular-templatecache'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'

module.exports = ->
  pipe gulp.src(paths.js.core), [
    coffee(bare: true),                         # convert from coffeescript to js
    append.obj(pipe gulp.src(paths.html.core), [  # build html template cache
      haml(),                                     # convert haml to html
      htmlmin(),                                  # minify html
      template(                                   # store html templates in angular cache
        module: 'loomioApp',
        transformUrl: (url) -> "generated/components/#{url}"
      ),
    ]),
    concat('app.js'),                           # concatenate app files
    gulp.dest(paths.dist.assets)                # write assets/app.js
    uglify(),                                   # minify app.js file
    rename(suffix: '.min'),                     # rename stream to app.min.js
    gulp.dest(paths.dist.assets)                # write assets/app.min.js
  ]
