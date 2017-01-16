angular.module('loomioApp').directive 'pollCheckInActionPanel', (ModalService, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/check_in/action_panel/poll_check_in_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.currentUserStance = ->
      $scope.poll.stanceFor(Session.user())

    $scope.userHasVoted = ->
      $scope.currentUserStance()?

    $scope.myStance = $scope.currentUserStance() or
                      Records.stances.build(pollId: $scope.poll.id)

    # $scope.openOutcomeForm = ->
    #   ModalService.open PollCheckInOutcomeForm, outcome: ->
    #     $scope.poll.outcome() or
    #     Records.outcomes.build(pollId: $scope.poll.id)
