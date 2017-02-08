angular.module('loomioApp').directive 'pollCommonOutcomePanel', (Records, ModalService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/outcome_panel/poll_common_outcome_panel.html'
  controller: ($scope) ->
    showUpdateButton: ->
      AbilityService.canSetPollOutcome($scope.poll)
