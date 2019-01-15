AbilityService = require 'shared/services/ability_service'

{ iconFor } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonCardHeader', ->
  scope: {poll: '='}
  template: require('./poll_common_card_header.haml')
  controller: ['$scope', ($scope) ->
    $scope.pollHasActions = ->
      AbilityService.canEditPoll($scope.poll)  ||
      AbilityService.canClosePoll($scope.poll) ||
      AbilityService.canDeletePoll($scope.poll)||
      AbilityService.canExportPoll($scope.poll)

    $scope.icon = ->
      iconFor($scope.poll)
  ]
