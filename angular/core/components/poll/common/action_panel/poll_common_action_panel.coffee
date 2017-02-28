angular.module('loomioApp').directive 'pollCommonActionPanel', ($location, ModalService, Records, PollCommonEditVoteModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/action_panel/poll_common_action_panel.html'
  controller: ($scope, Records, Session) ->

    $scope.init = ->
      $scope.stance = $scope.poll.lastStanceByUser(Session.user()) or
                      Records.stances.build(pollId: $scope.poll.id).choose($location.search().poll_option_id)
    $scope.$on 'refreshStance', $scope.init
    $scope.init()

    $scope.userHasVoted = ->
      $scope.poll.lastStanceByUser(Session.user())

    $scope.openStanceForm = ->
      ModalService.open PollCommonEditVoteModal, stance: -> $scope.stance
