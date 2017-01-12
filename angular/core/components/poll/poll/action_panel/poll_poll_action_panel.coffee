angular.module('loomioApp').directive 'pollPollActionPanel', (ModalService, Records, PollPollVoteForm, PollProposalOutcomeForm) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/poll/action_panel/poll_poll_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.currentUserStance = ->
      $scope.poll.stanceFor(Session.user())

    $scope.userHasVoted = ->
      $scope.currentUserStance()?

    $scope.openVoteForm = (option) ->
      ModalService.open PollPollVoteForm,
        stance: -> $scope.currentUserStance() or Records.stances.build(pollId: $scope.poll.id)
        option: -> option or $scope.currentUserStance().pollOption()

    $scope.openOutcomeForm = ->
      ModalService.open PollProposalOutcomeForm, outcome: ->
        $scope.poll.outcome() or
        Records.outcomes.build(pollId: $scope.poll.id)
