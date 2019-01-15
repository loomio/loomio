Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'pollCommonSetOutcomePanel', ->
  scope: {poll: '='}
  template: require('./poll_common_set_outcome_panel.haml')
  controller: ['$scope', ($scope) ->
    $scope.showPanel = ->
      !$scope.poll.outcome() and AbilityService.canSetPollOutcome($scope.poll)

    $scope.openOutcomeForm = ->
      ModalService.open 'PollCommonOutcomeModal', outcome: ->
        $scope.poll.outcome() or
        Records.outcomes.build(pollId: $scope.poll.id)
  ]
