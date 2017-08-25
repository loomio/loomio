angular.module('loomioApp').directive 'pollCommonSetOutcomePanel', (Records, ModalService, PollCommonOutcomeModal, AbilityService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/set_outcome_panel/poll_common_set_outcome_panel.html'
  controller: ($scope) ->
    $scope.showPanel = ->
      !$scope.poll.outcome() and AbilityService.canSetPollOutcome($scope.poll)

    $scope.openOutcomeForm = ->
      ModalService.open PollCommonOutcomeModal, outcome: ->
        $scope.poll.outcome() or
        Records.outcomes.build(pollId: $scope.poll.id)
