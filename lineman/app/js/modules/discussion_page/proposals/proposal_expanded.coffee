angular.module('loomioApp').directive 'proposalCard', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/proposal_card.html'
  replace: true
  controller: 'ProposalCardController'
  link: (scope, element, attrs) ->
