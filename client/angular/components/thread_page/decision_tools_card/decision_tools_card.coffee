AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'decisionToolsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/decision_tools_card/decision_tools_card.html'
  replace: true
  controller: ($scope) ->
    $scope.canStartPoll = ->
      AbilityService.canStartPoll(@discussion.group())
