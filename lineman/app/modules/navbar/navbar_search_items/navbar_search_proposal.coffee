angular.module('loomioApp').directive 'navbarSearchProposal', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/navbar/navbar_search_items/navbar_search_proposal.html'
  replace: true
  link: (scope, element, attrs) ->
