angular.module('loomioApp').directive 'proposalCardCollapsed', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/proposal_card_collapsed.html'
  replace: true
  controller: 'ProposalCardController'
  link: (scope, element, attrs) ->
