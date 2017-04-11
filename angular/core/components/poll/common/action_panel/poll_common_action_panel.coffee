angular.module('loomioApp').directive 'pollCommonActionPanel', ($location, AppConfig, ModalService, AbilityService, PollService, Session, Records, PollCommonEditVoteModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/action_panel/poll_common_action_panel.html'
  controller: ($scope, Records, Session) ->

    $scope.init = ->
      $scope.stance = PollService.lastStanceBy(Session.participant(), $scope.poll) or
                      Records.stances.build(
                        pollId:    $scope.poll.id,
                        visitorId: AppConfig.currentVisitorId,
                        userId:    AppConfig.currentUserId
                      ).choose($location.search().poll_option_id)

    $scope.$on 'refreshStance', $scope.init
    $scope.init()

    $scope.userHasVoted = ->
      PollService.hasVoted(Session.participant(), $scope.poll)

    $scope.openStanceForm = ->
      ModalService.open PollCommonEditVoteModal, stance: -> $scope.init()
