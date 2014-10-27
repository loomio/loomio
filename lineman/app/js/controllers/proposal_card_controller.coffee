angular.module('loomioApp').controller 'ProposalCardController', ($scope, $modal, ProposalService, UserAuthService, VoteModel) ->
  $scope.currentUser = UserAuthService.currentUser

  $scope.currentUserHasVoted = ->
    return false unless $scope.proposal
    $scope.proposal.userHasVoted(UserAuthService.currentUser)

  $scope.lastVoteByCurrentUser = ->
    # maybe return nullvote object
    return false unless $scope.proposal
    $scope.proposal.lastVoteByUser(UserAuthService.currentUser)
