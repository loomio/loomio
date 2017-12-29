angular.module('loomioApp').factory 'PollCommonOutcomeModal', ->
  templateUrl: 'generated/components/poll/common/outcome_modal/poll_common_outcome_modal.html'
  controller: ['$scope', 'outcome', ($scope, outcome) ->
    $scope.outcome = outcome.clone()
    $scope.$on 'outcomeSaved', $scope.$close
  ]
