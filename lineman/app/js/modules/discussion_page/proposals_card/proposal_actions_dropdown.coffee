angular.module('loomioApp').directive 'proposalActionsDropdown', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/discussion_page/proposals_card/proposal_actions_dropdown.html'
  replace: true
  controller: 'ProposalActionsDropdownController'
  link: (scope, element, attrs) ->
