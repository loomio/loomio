angular.module('loomioApp').controller 'ProposalsCardController', ($scope, Records) ->
  Records.proposals.fetchByDiscussion $scope.discussion
  Records.votes.fetchMyVotesByDiscussion $scope.discussion

  $scope.isSelectedProposal = (proposal) ->
    if $scope.selectedProposal? and proposal?
      $scope.selectedProposal.id == proposal.id

  $scope.setSelectedProposal = (proposal) ->
    $scope.selectedProposal = proposal

  if $scope.discussion.activeProposal()?
    $scope.setSelectedProposal $scope.discussion.activeProposal()
