angular.module('loomioApp').directive 'pollCommonDirective', ($compile, $injector) ->
  scope: {poll: '=?', stance: '=?', back: '=?', name: '@'}
  link: ($scope, element) ->
    $scope.poll = $scope.stance.poll() if $scope.stance and !$scope.poll
    if $injector.has(_.camelCase("poll_#{$scope.poll.pollType}_#{$scope.name}_directive"))
      element.append $compile("<poll_#{$scope.poll.pollType}_#{$scope.name} poll='poll' stance='stance' back='back' />")($scope)
    else
      element.append $compile("<poll_common_#{$scope.name} poll='poll' stance='stance' back='back' />")($scope)
