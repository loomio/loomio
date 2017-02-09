angular.module('loomioApp').directive 'pollCommonCardHeader', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/card_header/poll_common_card_header.html'
  controller: ($scope, AbilityService, PollService) ->
    $scope.pollHasActions = ->
      AbilityService.canEditPoll($scope.poll) ||
      AbilityService.canClosePoll($scope.poll)

    $scope.icon = ->
      PollService.fieldFromTemplate($scope.poll.pollType, 'material_icon')
