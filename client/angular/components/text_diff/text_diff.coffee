DiffMatchPatch = require 'diff-match-patch'

angular.module('loomioApp').directive 'textDiff', ->
  scope: {before: '=', after: '='}
  restrict: 'E'
  templateUrl: 'generated/components/text_diff/text_diff.html'
  controller: ['$scope', ($scope) ->
    $scope.diff = ->
      diff = new DiffMatchPatch()
      diff.diff_prettyHtml diff.diff_main($scope.before, $scope.after)
  ]
