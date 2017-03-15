angular.module('loomioApp').directive 'pollCommonActionPanel', ($location, ModalService, AbilityService, Records, PollCommonEditVoteModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/action_panel/poll_common_action_panel.html'
  controller: ($scope, Records, Session) ->

    $scope.init = ->
      $scope.stance = $scope.poll.lastStanceByUser() or
                      Records.stances.build(pollId: $scope.poll.id).choose($location.search().poll_option_id)
      $scope.showSubscribeForm = !AbilityService.isLoggedIn() and
                                 $scope.stance.participant() and
                                 !$scope.stance.participant().email?

    $scope.$on 'refreshStance', $scope.init
    $scope.$on 'subscribeFormDismissed', -> $scope.showSubscribeForm = false
    $scope.init()

    $scope.userHasVoted = ->
      $scope.poll.lastStanceByUser()

    $scope.openStanceForm = ->
      ModalService.open PollCommonEditVoteModal, stance: -> $scope.stance
