angular.module('loomioApp').directive 'discussionProposalCollapsed', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/discussion_proposal_collapsed.html'
  replace: true
  controller: 'DiscussionProposalController'
  link: (scope, element, attrs) ->
