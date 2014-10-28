angular.module('loomioApp').controller 'ProposalCardController', ($scope, $modal, ProposalService, UserAuthService, VoteModel) ->
  currentUser = UserAuthService.currentUser

  $scope.pieChartData = []

  $scope.pieChartOptions =  {}

  refreshPieChartData = ->
    counts = $scope.proposal.voteCounts
    $scope.pieChartData = [
      { value : counts.yes, color : "#90D490" },
      { value : counts.abstain, color : "#F0BB67" },
      { value : counts.no, color : "#D49090" },
      { value : counts.block, color : "#dd0000"}
    ]
  refreshPieChartData()

  $scope.$on 'newVote', ->
    alert('new vote emitted')
    refreshPieChartData()

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

