AbilityService = require 'shared/services/ability_service'

angular.module('loomioApp').directive 'decisionToolsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  template: require('./decision_tools_card.haml')
  controller: ['$scope', ($scope) ->
    $scope.canStartPoll = ->
      AbilityService.canStartPoll($scope.discussion)
  ]
