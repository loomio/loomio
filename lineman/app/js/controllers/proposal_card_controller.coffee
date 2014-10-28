angular.module('loomioApp').controller 'ProposalCardController', ($scope, $modal, ProposalService, UserAuthService, VoteModel) ->
  currentUser = UserAuthService.currentUser

  $scope.pieChartData = [
    { value : 0, color : "#90D490" },
    { value : 0, color : "#F0BB67" },
    { value : 0, color : "#D49090" },
    { value : 0, color : "#dd0000"}
  ]

  $scope.pieChartOptions =
    animation: false
    segmentShowStroke : false
    responsive: true

  refreshPieChartData = ->
    return unless $scope.proposal
    counts = $scope.proposal.voteCounts
    # yeah - this is done to preseve the view binding on the pieChartData
    $scope.pieChartData[0].value = counts.yes
    $scope.pieChartData[1].value = counts.abstain
    $scope.pieChartData[2].value = counts.no
    $scope.pieChartData[3].value = counts.block

  refreshPieChartData()

  $scope.$on 'newVote', ->
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

