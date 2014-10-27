angular.module('loomioApp').controller 'ProposalCardController', ($scope, $modal, ProposalService, UserAuthService, VoteModel) ->
  currentUser = UserAuthService.currentUser

  filteredVotes = ->
    _.filter $scope.proposal.votes(), (vote) ->
      vote.authorId != currentUser.id

  $scope.curatedVotes = ->
    positionValues = {yes: 0, abstain: 1, no: 3, block: 3}
    _.sortBy filteredVotes(), (vote) ->
      positionValues[vote.position]

  $scope.currentUserHasVoted = ->
    return false unless $scope.proposal
    $scope.proposal.userHasVoted(currentUser)

