angular.module('loomioApp').directive 'startProposalCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/start_proposal_card/start_proposal_card.html'
  replace: true
