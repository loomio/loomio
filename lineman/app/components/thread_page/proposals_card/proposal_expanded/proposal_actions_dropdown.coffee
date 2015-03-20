angular.module('loomioApp').directive 'proposalActionsDropdown', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposals_card/proposal_expanded/proposal_actions_dropdown.html'
  replace: true
  controller: 'ProposalActionsDropdownController'
  link: (scope, element, attrs) ->
