angular.module('loomioApp').directive 'proposalCollapsed', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/discussion_page/proposals_card/proposal_collapsed.html'
  replace: true
  controller: 'ProposalController'
  link: (scope, element, attrs) ->
