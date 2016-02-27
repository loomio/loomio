angular.module('loomioApp').directive 'previousProposalsCard', ($routeParams) ->
  scope: {discussion: '=', active: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/previous_proposals_card/previous_proposals_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, Records) ->

    Records.votes.fetchMyVotes($scope.discussion)
    Records.proposals.fetchByDiscussion($scope.discussion).then ->
      $rootScope.$broadcast 'threadPageProposalsLoaded'

    $scope.setSelectedProposal = ->
      $scope.selectedProposalId = $scope.active or setLastClosedProposal()

    setLastClosedProposal = ->
      return unless $scope.anyProposals() and !$scope.discussion.hasActiveProposal()
      proposal = $scope.discussion.closedProposals()[0]
      proposal.id if moment().add(-1, 'month') < proposal.closedAt

    $scope.$on 'setSelectedProposal', $scope.setSelectedProposal

    $scope.anyProposals = ->
      $scope.discussion.closedProposals().length > 0

    return
