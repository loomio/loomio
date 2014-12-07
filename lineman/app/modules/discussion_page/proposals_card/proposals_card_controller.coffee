angular.module('loomioApp').controller 'ProposalsCardController', ($scope, Records) ->
  Records.proposals.fetchByDiscussion $scope.discussion
  Records.votes.fetchMyVotesByDiscussion $scope.discussion

  $scope.isExpanded = (proposal) ->
    if $scope.expandedProposal? and proposal?
      $scope.expandedProposal.id == proposal.id

  $scope.expand = (proposal) ->
    Records.votes.fetchByProposal(proposal)
    $scope.expandedProposal = proposal

  if $scope.discussion.activeProposal()?
    $scope.expand($scope.discussion.activeProposal())
