angular.module('loomioApp').directive 'pollPollActionPanel', (ModalService, Records, PollPollVoteForm, PollCommonOutcomeForm) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/poll/action_panel/poll_poll_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.currentUserStance = ->
      $scope.poll.stanceFor(Session.user())

    $scope.userHasVoted = ->
      $scope.currentUserStance()?

    $scope.openVoteForm = (option) ->
      # only time option is passed is new stance.
      stance = $scope.currentUserStance() or
               Records.stances.build(pollId: $scope.poll.id).choose([option])
      ModalService.open PollPollVoteForm,
        stance: -> stance

    $scope.openOutcomeForm = ->
      ModalService.open PollCommonOutcomeForm, outcome: ->
        $scope.poll.outcome() or
        Records.outcomes.build(pollId: $scope.poll.id)
