angular.module('loomioApp').directive 'discussionProposalCollaped', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/dicsussion_proposal_collapsed.html'
  replace: true
  controller: 'DiscussionProposalCollapsedController'
  link: (scope, element, attrs) ->
