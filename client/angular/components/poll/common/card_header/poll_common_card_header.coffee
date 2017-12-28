AbilityService = require 'shared/services/ability_service.coffee'

{ iconFor } = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').directive 'pollCommonCardHeader', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/card_header/poll_common_card_header.html'
  controller: ($scope) ->
    $scope.pollHasActions = ->
      AbilityService.canSharePoll($scope.poll) ||
      AbilityService.canEditPoll($scope.poll)  ||
      AbilityService.canClosePoll($scope.poll) ||
      AbilityService.canDeletePoll($scope.poll)

    $scope.icon = ->
      iconFor($scope.poll)
