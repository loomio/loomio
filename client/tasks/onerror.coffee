plumber = require 'gulp-plumber'
gutil   = require 'gulp-util'

module.exports = (err) ->
  gutil.log(gutil.colors.red('[Error]'), err.toString())
