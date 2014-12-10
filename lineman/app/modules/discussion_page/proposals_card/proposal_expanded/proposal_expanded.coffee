angular.module('loomioApp').directive 'proposalExpanded', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/proposals_card/proposal_expanded/proposal_expanded.html'
  replace: true
  controller: 'ProposalExpandedController'
  link: (scope, element, attrs) ->
