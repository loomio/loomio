Records = require 'shared/services/records'

{ applySequence } = require 'shared/helpers/apply'

angular.module('loomioApp').factory 'PollCommonOutcomeModal', ->
  templateUrl: 'generated/components/poll/common/outcome/modal/poll_common_outcome_modal.html'
  controller: ['$scope', 'outcome', ($scope, outcome) ->
    $scope.outcome = outcome.clone()

    applySequence $scope,
      steps: ['save', 'announce']
      saveComplete: (_, event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)
  ]
