angular.module('loomioApp').directive 'proposals', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/proposals.html'
  replace: true
  controller: 'ProposalsController'
  link: (scope, element, attrs) ->
