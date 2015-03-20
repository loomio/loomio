angular.module('loomioApp').controller 'ProposalExpandedController', ($scope, $modal, Records, UserAuthService) ->
  Records.votes.fetchByProposal($scope.proposal)
  currentUser = window.Loomio.currentUser
  $scope.showVotes = false

  $scope.showActionsDropdown = ->
    currentUser.canCloseOrExtendProposal($scope.proposal)

  filteredVotes = ->
    return [] unless $scope.proposal
    _.filter $scope.proposal.uniqueVotes(), (vote) ->
      vote.authorId != currentUser.id

  $scope.onlyVoterIsYou = ->
    return false unless $scope.proposal
    uniqueVotes = $scope.proposal.uniqueVotes()
    (uniqueVotes.length == 1) and (uniqueVotes[0].authorId == currentUser.id)

  $scope.noVotesYet = ->
    return true unless $scope.proposal
    $scope.proposal.votes().length == 0

  $scope.curatedVotes = ->
    positionValues = {yes: 0, abstain: 1, no: 2, block: 3}
    _.sortBy filteredVotes(), (vote) ->
      positionValues[vote.position]

  $scope.currentUserHasVoted = ->
    return false unless $scope.proposal
    $scope.proposal.userHasVoted(currentUser)

  $scope.currentUserVote = ->
    return false unless $scope.proposal
    $scope.proposal.lastVoteByUser(currentUser)

  $scope.showVoteToggle = ->
    $scope.curatedVotes().length > 0 and !$scope.showVotes

  $scope.applyVoteToggle = ->
    $scope.showVotes = !$scope.showVotes
