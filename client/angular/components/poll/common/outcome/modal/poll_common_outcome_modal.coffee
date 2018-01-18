EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').factory 'PollCommonOutcomeModal', ->
  templateUrl: 'generated/components/poll/common/outcome/modal/poll_common_outcome_modal.html'
  controller: ['$scope', 'outcome', ($scope, outcome) ->
    $scope.outcome = outcome.clone()
    EventBus.listen $scope, 'nextStep', $scope.$close
  ]
