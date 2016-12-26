angular.module('loomioApp').directive 'pollSummaryPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/summary_panel/poll_summary_panel.html'
  controller: ($scope, AbilityService) ->
    $scope.pollHasActions = ->
      AbilityService.canEditPoll($scope.poll) ||
      AbilityService.canClosePoll($scope.poll)
