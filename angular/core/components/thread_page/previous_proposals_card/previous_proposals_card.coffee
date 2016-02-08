angular.module('loomioApp').directive 'previousProposalsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/previous_proposals_card/previous_proposals_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, Records, ProposalFormService) ->

    Records.votes.fetchMyVotes($scope.discussion)
    Records.proposals.fetchByDiscussion($scope.discussion).then ->
      $scope.setSelectedProposal()
      $rootScope.$broadcast 'threadPageProposalsLoaded'

    $scope.setSelectedProposal = ->
      $scope.selectedProposalId = setProposalFromQueryParameter() or setLastClosedProposal()

    setProposalFromQueryParameter = ->
      proposal = Records.proposals.find($location.search().proposal)
      proposal.id if proposal

    setLastClosedProposal = ->
      return unless $scope.anyProposals() and !$scope.discussion.hasActiveProposal()
      proposal = $scope.discussion.closedProposals()[0]
      proposal if moment().add(-1, 'month') < proposal.closedAt

    $scope.$on 'setSelectedProposal', $scope.setSelectedProposal

    $scope.anyProposals = ->
      $scope.discussion.closedProposals().length > 0

    return
