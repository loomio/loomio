angular.module('loomioApp').directive 'pollProposalVotesPanel', (Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/votes_panel/poll_proposal_votes_panel.html'
  controller: ($scope) ->
    Records.stances.fetch(params: {poll_id: $scope.poll.key})
