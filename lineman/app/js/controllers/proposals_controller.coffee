angular.module('loomioApp').controller 'ProposalsController', ($scope, VoteService, ProposalService, ProposalModel, UserAuthService) ->

  ProposalService.fetchByDiscussion $scope.discussion, ->
    VoteService.fetchMyVotes($scope.discussion)

  $scope.isSelectedProposal = (proposal) ->
    if $scope.selectedProposal? and proposal?
      $scope.selectedProposal.id == proposal.id

  $scope.setSelectedProposal = (proposal) ->
    $scope.selectedProposal = proposal
    VoteService.fetchByProposal(proposal)

  if $scope.discussion.activeProposal()?
    $scope.setSelectedProposal $scope.discussion.activeProposal()
