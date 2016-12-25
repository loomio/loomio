angular.module('loomioApp').directive 'pollProposalOptionsPanel', (ModalService, Records, PollProposalVoteForm) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/options_panel/poll_proposal_options_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.currentUserStance = ->
      Records.stances.find(pollId: $scope.poll.id, participantId: Session.user().id)[0]

    $scope.userHasVoted = ->
      $scope.currentUserStance()?

    $scope.openVoteForm = (option) ->
      ModalService.open PollProposalVoteForm, stance: ->
        $scope.currentUserStance() or
        Records.stances.build(pollId: $scope.poll.id, pollOptionId: option.id)
