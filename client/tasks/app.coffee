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
coffeeify  = require 'coffeeify'
glob       = require 'globby'
source     = require 'vinyl-source-stream'
fs         = require 'fs'
_          = require 'lodash'
gutil      = require 'gulp-util'

module.exports =
  require: ->
    fs.writeFile(paths.app.main, _.flatten(_.map paths.app.folders, (folder) ->
      _.map glob.sync("angular/#{folder}/**/*.coffee"), (file) ->
        "require '#{file}'"
    ).join("\n"))

  browserify: ->
    pipe browserify(
      entries: [paths.app.main]
      transform: [coffeeify]
      paths: ['./', './node_modules']
    ).bundle().on('error', (err) -> console.log(err)), [
      source('app.js'),
      gulp.dest(paths.dist.assets)
    ]

  haml: ->
    pipe gulp.src(paths.app.haml), [
      haml(),
      htmlmin(),
      template(
        module: 'loomioApp',
        transformUrl: (url) ->
          if url.match /.+\/.+/
            "generated/components/#{url}"
          else
            "generated/components/#{url.split('.')[0]}/#{url}"
      )
      concat('templates.js')
      gulp.dest(paths.dist.assets)
    ]

  scss: ->
    pipe gulp.src(paths.app.scss), [
      plumber(errorHandler: onError),                # handle errors gracefully
      replace('screen\\0','screen'),                 # workaround for https://github.com/angular/material/issues/6304
      concat('app.css'),                             # concatenate scss files
      sass(includePaths: paths.app.scss_include),    # convert scss to css (include vendor path for @imports)
      gulp.dest(paths.dist.assets)                   # write assets/app.min.css
    ]
