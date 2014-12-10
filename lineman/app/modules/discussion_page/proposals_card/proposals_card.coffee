angular.module('loomioApp').directive 'proposalsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/proposals_card/proposals_card.html'
  replace: true
  controller: 'ProposalsCardController'
  link: (scope, element, attrs) ->
