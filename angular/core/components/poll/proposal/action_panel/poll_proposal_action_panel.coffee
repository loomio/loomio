angular.module('loomioApp').directive 'pollProposalActionPanel', (ModalService, Records, PollProposalVoteForm, PollProposalOutcomeForm) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/action_panel/poll_proposal_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.currentUserStance = ->
      $scope.poll.stanceFor(Session.user())

    $scope.userHasVoted = ->
      $scope.currentUserStance()?

    $scope.openVoteForm = (option) ->
      ModalService.open PollProposalVoteForm,
        stance: -> $scope.currentUserStance() or Records.stances.build(pollId: $scope.poll.id)
        option: -> option

    $scope.openOutcomeForm = ->
      ModalService.open PollProposalOutcomeForm, outcome: ->
        $scope.poll.outcome() or
        Records.outcomes.build(pollId: $scope.poll.id)
