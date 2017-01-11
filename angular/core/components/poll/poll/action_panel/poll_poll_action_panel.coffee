angular.module('loomioApp').directive 'pollPollActionPanel', (ModalService, Records, PollPollVoteForm, PollProposalOutcomeForm) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/poll/action_panel/poll_poll_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.currentUserStance = ->
      $scope.poll.stanceFor(Session.user())

    $scope.userHasVoted = ->
      $scope.currentUserStance()?

    $scope.openVoteForm = (name) ->
      option = Records.pollOptions.find(pollId: $scope.poll.id, name: name)[0] or {}
      ModalService.open PollPollVoteForm, stance: ->
        $scope.currentUserStance() or
        Records.stances.build(pollId: $scope.poll.id, pollOptionId: option.id)

    $scope.openOutcomeForm = ->
      ModalService.open PollProposalOutcomeForm, outcome: ->
        $scope.poll.outcome() or
        Records.outcomes.build(pollId: $scope.poll.id)
