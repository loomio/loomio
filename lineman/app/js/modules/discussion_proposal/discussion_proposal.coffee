angular.module('loomioApp').directive 'discussionProposal', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/discussion_proposal.html'
  replace: true
  controller: 'DiscussionProposalController'
  link: (scope, element, attrs) ->
