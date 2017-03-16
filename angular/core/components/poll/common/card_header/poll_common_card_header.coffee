angular.module('loomioApp').directive 'pollCommonCardHeader', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/card_header/poll_common_card_header.html'
  controller: ($scope, AbilityService, PollService) ->
    $scope.pollHasActions = ->
      AbilityService.canSharePoll($scope.poll) ||
      AbilityService.canEditPoll($scope.poll) ||
      AbilityService.canClosePoll($scope.poll)

    $scope.icon = ->
      PollService.iconFor($scope.poll)
