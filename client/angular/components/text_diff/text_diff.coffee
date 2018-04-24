DiffMatchPatch = require 'diff-match-patch'

angular.module('loomioApp').directive 'textDiff', ->
  scope: {before: '=', after: '='}
  restrict: 'E'
  templateUrl: 'generated/components/text_diff/text_diff.html'
  controller: ['$scope', ($scope) ->
    $scope.diff = ->
      differ = new DiffMatchPatch()
      diff = differ.diff_main($scope.before||"", $scope.after||"")
      differ.diff_cleanupSemantic(diff)
      $scope.prettyHtml(diff)

    $scope.prettyHtml = (diff) ->
      diff.reduce((whole, [sign, chars] ) ->
        whole + switch sign
          when -1 then   "<del>#{chars}</del>"
          when  0 then   "<span>#{chars}</span>"
          when  1 then   "<ins>#{chars}</ins>"
      , "")
  ]
