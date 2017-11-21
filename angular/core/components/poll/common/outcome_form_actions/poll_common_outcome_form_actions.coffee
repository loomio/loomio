angular.module('loomioApp').directive 'pollCommonOutcomeFormActions', ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/outcome_form_actions/poll_common_outcome_form_actions.html'
  controller: ($scope, PollService, KeyEventService) ->
    $scope.submit = PollService.submitOutcome $scope, $scope.outcome

    KeyEventService.submitOnEnter($scope)
