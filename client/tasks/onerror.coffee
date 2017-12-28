plumber = require 'gulp-plumber'
util    = require 'gulp-util'

module.exports = (err) ->
  gutil.log(gutil.colors.red('[Error]'), err.toString())
