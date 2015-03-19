angular.module('loomioApp').directive 'proposalExpanded', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposals_card/proposal_expanded/proposal_expanded.html'
  replace: true
  controller: 'ProposalExpandedController'
