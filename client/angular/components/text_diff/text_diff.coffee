
{compileDiffHtml} = require "shared/helpers/text.coffee"

angular.module('loomioApp').directive 'textDiff', ->
  scope: {before: '=', after: '='}
  restrict: 'E'
  template: require('./text_diff.haml')
  controller: ['$scope', ($scope) ->
    $scope.diff = ->
      compileDiffHtml($scope.before, $scope.after)
  ]
