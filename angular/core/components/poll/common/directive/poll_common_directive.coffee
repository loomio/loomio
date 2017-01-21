angular.module('loomioApp').directive 'pollCommonDirective', ($compile) ->
  scope: {poll: '=', name: '@'}
  link: ($scope, element) ->
    element.append $compile("<poll_#{$scope.poll.pollType}_#{$scope.name} poll='poll' />")($scope)
