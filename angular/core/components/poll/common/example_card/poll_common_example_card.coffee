angular.module('loomioApp').directive 'pollCommonExampleCard', ($translate) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/example_card/poll_common_example_card.html'
  replace: true
  controller: ($scope) ->
    $scope.type = ->
      $translate.instant("poll_types.#{$scope.poll.pollType}").toLowerCase()
