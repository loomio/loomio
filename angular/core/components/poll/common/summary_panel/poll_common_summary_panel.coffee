angular.module('loomioApp').directive 'pollCommonSummaryPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/summary_panel/poll_common_summary_panel.html'
  controller: ($scope, AbilityService, PollService) ->
    $scope.pollHasActions = ->
      AbilityService.canEditPoll($scope.poll) ||
      AbilityService.canClosePoll($scope.poll)

    $scope.icon = ->
      PollService.fieldFromTemplate($scope.poll.pollType, 'material_icon')
