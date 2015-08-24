angular.module('loomioApp').directive 'starToggle', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/star_toggle/star_toggle.html'
  replace: true
  controller: ($scope, $rootScope) ->
    $scope.toggle = ->
      $scope.thread.toggleStar()
      $rootScope.$broadcast 'starToggled', $scope.thread
