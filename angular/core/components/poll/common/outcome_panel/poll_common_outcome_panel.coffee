angular.module('loomioApp').directive 'pollCommonOutcomePanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/outcome_panel/poll_common_outcome_panel.html'
  controller: ($scope, ModalService, AbilityService, PollCommonOutcomeForm) ->
    $scope.showUpdateButton = ->
      AbilityService.canSetPollOutcome($scope.poll)

    $scope.openOutcomeForm = ->
      ModalService.open PollCommonOutcomeForm, outcome: -> $scope.poll.outcome()
