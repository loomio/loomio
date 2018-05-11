AbilityService = require 'shared/services/ability_service'

angular.module('loomioApp').directive 'decisionToolsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/decision_tools_card/decision_tools_card.html'
  controller: ['$scope', ($scope) ->
    $scope.canStartPoll = ->
      AbilityService.canStartPoll($scope.discussion)
  ]
