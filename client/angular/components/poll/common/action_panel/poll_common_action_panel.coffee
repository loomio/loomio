AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'pollCommonActionPanel', ($location, ModalService, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/action_panel/poll_common_action_panel.html'
  controller: ($scope, Records, Session) ->

    $scope.init = ->
      token      = $location.search().invitation_token
      invitation = _.first(Records.invitations.find(token: token)) unless $scope.poll.example
      $scope.stance = PollService.lastStanceBy(Session.user(), $scope.poll) or
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
      PollService.hasVoted(Session.user(), $scope.poll)

    $scope.userCanParticipate = ->
      AbilityService.canParticipateInPoll($scope.poll)

    $scope.openStanceForm = ->
      ModalService.open 'PollCommonEditVoteModal', stance: -> $scope.init()
