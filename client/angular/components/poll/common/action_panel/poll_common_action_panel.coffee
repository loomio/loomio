AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
LmoUrlService  = require 'shared/services/lmo_url_service'

{ myLastStanceFor } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonActionPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/action_panel/poll_common_action_panel.html'
  controller: ['$scope', ($scope) ->

    $scope.init = ->
      $scope.stance = myLastStanceFor($scope.poll) or
                      Records.stances.build(
                        pollId:    $scope.poll.id,
                        userId:    AppConfig.currentUserId
                      ).choose(LmoUrlService.params().poll_option_id)

    EventBus.listen $scope, 'refreshStance', $scope.init
    $scope.init()

    $scope.userHasVoted = ->
      myLastStanceFor($scope.poll)?

    $scope.userCanParticipate = ->
      AbilityService.canParticipateInPoll($scope.poll)
  ]
