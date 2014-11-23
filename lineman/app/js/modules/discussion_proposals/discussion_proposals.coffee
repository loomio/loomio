angular.module('loomioApp').directive 'discussion_proposals', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/proposals.html'
  replace: true
  controller: 'DiscussionProposalsController'
  link: (scope, element, attrs) ->
