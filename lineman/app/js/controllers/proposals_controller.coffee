angular.module('loomioApp').controller 'ProposalsController', ($scope, VoteService, ProposalService, ProposalModel, UserAuthService) ->
  $scope.active = $scope.discussion.activeProposal()
  currentUser = UserAuthService.currentUser

  ProposalService.fetchByDiscussion $scope.discussion.id, (proposals) ->
    $scope.proposals = _.map proposals, (proposal) -> new ProposalModel(proposal)
    VoteService.fetchByCurrentUserAndDiscussion(currentUser.id, $scope.discussion.id)

  $scope.isActive = (proposal) ->
    proposal.id == $scope.active.id

  $scope.setActive = (proposal) ->
    $scope.active = proposal