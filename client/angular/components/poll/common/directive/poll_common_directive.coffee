angular.module('loomioApp').directive 'pollCommonDirective', ['$compile', '$injector', ($compile, $injector) ->
  scope: {poll: '=?', stance: '=?', outcome: '=?', stanceChoice: '=?', back: '=?', name: '@'}
  link: ($scope, $element) ->
    model = $scope.stance or $scope.outcome or $scope.stanceChoice or (poll: ->)
    $scope.poll = $scope.poll or model.poll()

    directiveName = if $injector.has(_.camelCase("poll_#{$scope.poll.pollType}_#{$scope.name}_directive"))
      "poll_#{$scope.poll.pollType}_#{$scope.name}"
    else
      "poll_common_#{$scope.name}"

    $compile("<#{directiveName} poll='poll' stance='stance' stance-choice='stanceChoice', outcome='outcome' back='back' />")($scope, (cloned) -> $element.append(cloned))
]
