###
Task: spec-e2e
Description: run protractor (in a ci-like mode)
Dependencies: grunt
Contributor: @searls
###
module.exports = (grunt) ->
  path = require("path")
  spawn = require("child_process").spawn

  grunt.registerTask "spec-e2e", "run specs in ci mode", (target) ->
    require('coffee-script')
    process.argv = ["doesnt", "matter", "#{process.cwd()}/config/spec-e2e.coffee"]
    done = @async()
    require("#{process.cwd()}/node_modules/protractor/lib/cli")
