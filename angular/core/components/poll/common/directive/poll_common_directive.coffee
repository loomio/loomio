angular.module('loomioApp').directive 'pollCommonDirective', ($compile, $injector) ->
  scope: {poll: '=?', stance: '=?', back: '=?', name: '@'}
  link: ($scope, element) ->
    $scope.poll = $scope.stance.poll() if $scope.stance and !$scope.poll

    directiveName = if $injector.has(_.camelCase("poll_#{$scope.poll.pollType}_#{$scope.name}_directive"))
      "poll_#{$scope.poll.pollType}_#{$scope.name}"
    else
      "poll_common_#{$scope.name}"

    element.append $compile("<#{directiveName} poll='poll' stance='stance' back='back' />")($scope)
