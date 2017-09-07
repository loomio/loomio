angular.module('loomioApp').directive 'pollCommonActionPanel', ($location, AppConfig, ModalService, AbilityService, PollService, Session, Records, PollCommonEditVoteModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/action_panel/poll_common_action_panel.html'
  controller: ($scope, Records, Session) ->

    $scope.init = ->
      invitation_token = $location.search().invitation_token
      $scope.invitation = Records.invitations.find(token: invitation_token)[0] || {}
      $scope.stance = PollService.lastStanceBy(Session.user(), $scope.poll) or
                      Records.stances.build(
                        pollId:    $scope.poll.id,
                        userId:    AppConfig.currentUserId,
                        token:     invitation_token
                        visitorAttributes: {email: $scope.invitation.recipientEmail}
                      ).choose($location.search().poll_option_id)

    $scope.$on 'refreshStance', $scope.init
    $scope.init()

    $scope.userHasVoted = ->
      PollService.hasVoted(Session.user(), $scope.poll)

    $scope.userCanParticipate = ->
      AbilityService.canParticipateInPoll($scope.poll)

    $scope.openStanceForm = ->
      ModalService.open PollCommonEditVoteModal, stance: -> $scope.init()
