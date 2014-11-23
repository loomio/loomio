angular.module('loomioApp').directive 'discussionProposals', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/discussion_proposals.html'
  replace: true
  controller: 'DiscussionProposalsController'
  link: (scope, element, attrs) ->
