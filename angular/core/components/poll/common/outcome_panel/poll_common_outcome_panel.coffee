angular.module('loomioApp').directive 'pollCommonOutcomePanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/outcome_panel/poll_common_outcome_panel.html'
  controller: ($scope, ModalService, AbilityService, PollCommonOutcomeModal) ->
    $scope.showUpdateButton = ->
      AbilityService.canSetPollOutcome($scope.poll)

    $scope.openOutcomeForm = ->
      ModalService.open PollCommonOutcomeModal, outcome: -> $scope.poll.outcome()
