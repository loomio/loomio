angular.module('loomioApp').directive 'pollProposalVotesPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/votes_panel/poll_proposal_votes_panel.html'
