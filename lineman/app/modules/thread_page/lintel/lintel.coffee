angular.module('loomioApp').directive 'lintel', ->
  scope: {discussion: '=', show: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/thread_page/lintel/lintel.html'
  replace: true
  controller: ($scope) ->
    $scope.show = false
