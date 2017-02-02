angular.module('loomioApp').directive 'pollCheckInActionPanel', ($location, ModalService, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/check_in/action_panel/poll_check_in_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.stance = $scope.poll.stanceFor(Session.user()) or
                    Records.stances.build(pollId: $scope.poll.id).choose($location.search().pollOptionId)

    $scope.userHasVoted = ->
      $scope.stance.id
