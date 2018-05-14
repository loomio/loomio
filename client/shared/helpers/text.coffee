DiffMatchPatch = require 'diff-match-patch'

prettyDiffHtml = (diff) ->
  diff.reduce((whole, [sign, chars] ) ->
    whole + switch sign
      when -1 then   "<del>#{chars}</del>"
      when  0 then   "<span>#{chars}</span>"
      when  1 then   "<ins>#{chars}</ins>"
  , "")

module.exports =
  compileDiffHtml: (before,  after)->
    differ = new DiffMatchPatch()
    diff = differ.diff_main(before||"", after||"")
    differ.diff_cleanupSemantic(diff)
    prettyDiffHtml(diff)
