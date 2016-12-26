angular.module('loomioApp').directive 'pollSummaryPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/summary_panel/poll_summary_panel.html'
  controller: ($scope, AbilityService, PollService) ->
    $scope.pollHasActions = ->
      AbilityService.canEditPoll($scope.poll) ||
      AbilityService.canClosePoll($scope.poll)

    $scope.icon = ->
      PollService.fieldFromTemplate($scope.poll.pollType, 'material_icon')
