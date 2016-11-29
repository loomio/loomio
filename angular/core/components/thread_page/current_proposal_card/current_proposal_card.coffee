angular.module('loomioApp').directive 'currentProposalCard', ->
  scope: {proposal: '=', loading: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/current_proposal_card/current_proposal_card.html'
  replace: true
