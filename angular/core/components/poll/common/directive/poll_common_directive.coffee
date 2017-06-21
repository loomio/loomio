angular.module('loomioApp').directive 'pollCommonDirective', ($compile, $injector) ->
  scope: {poll: '=?', stance: '=?', outcome: '=?', back: '=?', name: '@'}
  link: ($scope, element) ->
    model = $scope.stance or $scope.outcome or (poll: ->)
    $scope.poll = $scope.poll or model.poll()

    directiveName = if $injector.has(_.camelCase("poll_#{$scope.poll.pollType}_#{$scope.name}_directive"))
      "poll_#{$scope.poll.pollType}_#{$scope.name}"
    else
      "poll_common_#{$scope.name}"

    element.append $compile("<#{directiveName} poll='poll' stance='stance' outcome='outcome' back='back' />")($scope)
