
{compileDiffHtml} = require "shared/helpers/text.coffee"

angular.module('loomioApp').directive 'textDiff', ->
  scope: {before: '=', after: '='}
  restrict: 'E'
  templateUrl: 'generated/components/text_diff/text_diff.html'
  controller: ['$scope', ($scope) ->
    $scope.diff = ->
      compileDiffHtml($scope.before, $scope.after)
  ]
