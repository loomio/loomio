angular.module('loomioApp').directive 'previousProposalsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/previous_proposals_card/previous_proposals_card.html'
  replace: true
  controller: ($scope, $rootScope, Records) ->

    Records.votes.fetchMyVotes($scope.discussion)
    Records.proposals.fetchByDiscussion($scope.discussion).then ->
      $rootScope.$broadcast 'threadPageProposalsLoaded'

    lastRecentlyClosedProposal = ->
      return unless $scope.anyProposals() and !$scope.discussion.hasActiveProposal()
      proposal = $scope.discussion.closedProposals()[0]
      proposal if moment().add(-1, 'month') < proposal.closedOrClosingAt

    $scope.$on 'setSelectedProposal', (event, proposal) ->
      $scope.selectedProposalId = (proposal or lastRecentlyClosedProposal() or {}).id

    $scope.anyProposals = ->
      $scope.discussion.closedProposals().length > 0

    return
