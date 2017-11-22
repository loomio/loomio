angular.module('loomioApp').factory 'PollCommonOutcomeModal', (Records, SequenceService) ->
  templateUrl: 'generated/components/poll/common/outcome_modal/poll_common_outcome_modal.html'
  controller: ($scope, outcome) ->
    $scope.outcome = outcome.clone()

    SequenceService.applySequence $scope,
      steps: ['save', 'announce']
      saveComplete: (_, outcome) ->
        $scope.announcement = Records.announcements.buildFromModel(outcome)
