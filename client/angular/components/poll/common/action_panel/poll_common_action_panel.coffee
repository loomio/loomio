AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ myLastStanceFor } = require 'angular/helpers/poll.coffee'

angular.module('loomioApp').directive 'pollCommonActionPanel', ($location) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/action_panel/poll_common_action_panel.html'
  controller: ($scope) ->

    $scope.init = ->
      token      = $location.search().invitation_token
      invitation = _.first(Records.invitations.find(token: token)) unless $scope.poll.example
      $scope.stance = myLastStanceFor($scope.poll) or
                      Records.stances.build(
                        pollId:    $scope.poll.id,
                        userId:    AppConfig.currentUserId,
                        token:     token
                        visitorAttributes:
                          email: (invitation or {}).recipientEmail
                      ).choose($location.search().poll_option_id)

    $scope.$on 'refreshStance', $scope.init
    $scope.init()

    $scope.userHasVoted = ->
      myLastStanceFor($scope.poll)?

    $scope.userCanParticipate = ->
      AbilityService.canParticipateInPoll($scope.poll)

    $scope.openStanceForm = ->
      ModalService.open 'PollCommonEditVoteModal', stance: -> $scope.init()
