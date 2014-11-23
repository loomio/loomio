angular.module('loomioApp').controller 'DiscussionProposalController', ($scope, $modal, ProposalService, UserAuthService, VoteModel, VoteService) ->
  currentUser = UserAuthService.currentUser

  filteredVotes = ->
    return [] unless $scope.proposal
    _.filter $scope.proposal.votes(), (vote) ->
      vote.authorId != currentUser.id

  $scope.onlyVoterIsYou = ->
    return false unless $scope.proposal
    uniqueVotes = $scope.proposal.uniqueVotes()
    (uniqueVotes.length == 1) and (uniqueVotes[0].authorId == currentUser.id)

  $scope.noVotesYet = ->
    return true unless $scope.proposal
    $scope.proposal.votes().length == 0

  $scope.curatedVotes = ->
    positionValues = {yes: 0, abstain: 1, no: 3, block: 3}
    _.sortBy filteredVotes(), (vote) ->
      positionValues[vote.position]

  $scope.currentUserHasVoted = ->
    return false unless $scope.proposal
    $scope.proposal.userHasVoted(currentUser)

  $scope.currentUserVote = ->
    return false unless $scope.proposal
    $scope.proposal.lastVoteByUser(currentUser)


