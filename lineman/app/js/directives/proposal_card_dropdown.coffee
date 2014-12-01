angular.module('loomioApp').directive 'proposalCardDropdown', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/proposal_card_dropdown.html'
  replace: true
  controller: 'ProposalCardDropdownController'
  link: (scope, element, attrs) ->
