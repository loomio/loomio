angular.module('loomioApp').directive 'pollCommonOutcomePanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/outcome_panel/poll_common_outcome_panel.html'
  controller: ($scope, AbilityService) ->
    showUpdateButton: ->
      AbilityService.canSetPollOutcome($scope.poll)
