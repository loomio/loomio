angular.module('loomioApp').directive 'pollProposalActionPanel', (ModalService, Records, PollProposalEditVoteForm) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/action_panel/poll_proposal_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.currentUserStance = ->
      $scope.poll.stanceFor(Session.user())
    $scope.myNewStance = Records.stances.build(pollId: $scope.poll.id) unless $scope.currentUserStance()

    $scope.userHasVoted = ->
      $scope.currentUserStance()?

    $scope.openVoteForm = ->
      ModalService.open PollProposalEditVoteForm, stance: -> $scope.currentUserStance()
