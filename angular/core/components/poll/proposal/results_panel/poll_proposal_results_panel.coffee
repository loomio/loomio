angular.module('loomioApp').directive 'pollProposalResultsPanel', (Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/results_panel/poll_proposal_results_panel.html'
