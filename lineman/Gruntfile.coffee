#global module:false
module.exports = (grunt) ->
  require(process.env["LINEMAN_MAIN"]).config.grunt.run grunt
