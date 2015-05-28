angular.module('loomioApp').directive 'previousProposalsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/previous_proposals_card/previous_proposals_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, Records, ProposalFormService) ->

    Records.votes.fetchMyVotesByDiscussion($scope.discussion)
    Records.proposals.fetchByDiscussion($scope.discussion).then ->
      if target = $location.hash().match /^proposal-(\d+)$/
        if proposal = Records.proposals.find(parseInt(target[1]))
          $scope.selectProposal(proposal)
          selectedProposalId = proposal.id
      $rootScope.$broadcast 'threadPageProposalsLoaded', selectedProposalId

    $scope.selectedProposalId = 0

    $scope.anyProposals = ->
      $scope.discussion.closedProposals().length > 0


    $scope.$on 'collapseProposal', (event) ->
      $scope.selectedProposalId = 0

    $scope.proposals = ->
      $scope.discussion.closedProposals()

    $scope.selectProposal = (proposal) =>
      $scope.selectedProposalId = proposal.id

    return
