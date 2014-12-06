angular.module('loomioApp').directive 'proposalExpanded', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/proposals_card/proposal_expanded.html'
  replace: true
  controller: 'ProposalController'
  link: (scope, element, attrs) ->
