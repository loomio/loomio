angular.module('loomioApp').directive 'proposalCollapsed', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/thread_page/proposals_card/proposal_collapsed/proposal_collapsed.html'
  replace: true
  controller: ($scope) ->
