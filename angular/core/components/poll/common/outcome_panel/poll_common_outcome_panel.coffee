angular.module('loomioApp').directive 'pollCommonOutcomePanel', (Records, ModalService, PollCommonOutcomeForm) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/outcome_panel/poll_common_outcome_panel.html'
  controller: ($scope) ->

    $scope.openOutcomeForm = ->
      ModalService.open PollCommonOutcomeForm, outcome: ->
        $scope.poll.outcome() or
        Records.outcomes.build(pollId: $scope.poll.id)
