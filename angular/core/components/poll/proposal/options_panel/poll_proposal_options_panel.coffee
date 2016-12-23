angular.module('loomioApp').directive 'pollProposalOptionsPanel', (ModalService, Records, PollProposalVoteForm) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/options_panel/poll_proposal_options_panel.html'
  controller: ($scope) ->
    console.log 'controller'
    $scope.openVoteForm = (option) ->
      console.log 'open vote from'
      ModalService.open PollProposalVoteForm, stance: -> Records.stances.build(pollId: $scope.poll.id, pollOptionId: option.id)
