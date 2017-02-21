angular.module('loomioApp').directive 'pollCommonDirective', ($compile) ->
  scope: {poll: '=?', stance: '=?', name: '@'}
  link: ($scope, element) ->
    $scope.poll = $scope.stance.poll() if $scope.stance and !$scope.poll
    element.append $compile("<poll_#{$scope.poll.pollType}_#{$scope.name} poll='poll' stance='stance' />")($scope)
