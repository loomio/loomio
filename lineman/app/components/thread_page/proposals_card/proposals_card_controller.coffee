angular.module('loomioApp').controller 'ProposalsCardController', ($scope, Records) ->
  Records.proposals.fetchByDiscussion $scope.discussion
  Records.votes.fetchMyVotesByDiscussion $scope.discussion

  # if no selected proposal then any active proposal should be expanded
  # if selected proposal then that should be expanded
  # if no active or selected proposal... then all should be collapsed
  $scope.isExpanded = (proposal) ->
    if $scope.selectedProposal?
      proposal.id == $scope.selectedProposal.id
    else
      proposal.isActive()

  $scope.selectProposal = (proposal) ->
    $scope.selectedProposal = proposal
