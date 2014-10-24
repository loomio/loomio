angular.module('loomioApp').controller 'ProposalCardController', ($scope, $window, ProposalService, UserAuthService) ->
  $scope.voteFormIsDisabled = false
  $scope.voteFormIsExpanded = false

  $scope.newVote = {position: null, statement: null, proposalId: $scope.proposal.id}

  $scope.currentUserHasVoted = ->
    $scope.proposal.userHasVoted(UserAuthService.currentUser)


  $scope.currentUserVote = ->
    if $scope.proposal?
      index = $scope.proposal.votes().map((vote) -> vote.authorId).indexOf(UserAuthService.currentUser.id)
      $scope.proposal.votes()[index] if index?

  $scope.selectPosition = (position) ->
    $scope.newVote.position = position
    $scope.voteFormIsExpanded = true

    console.log $scope.proposal, position
    newProposal = angular.copy($scope.proposal)
    key = position + '_votes_count'
    newProposal[key] += 1
    newProposal.votes_count +=1

  $scope.submitVote = ->
    $scope.voteFormIsDisabled = true
    ProposalService.saveVote($scope.newVote, $scope.success, $scope.failure)

  $scope.success = (event) ->
    $scope.voteFormIsExpanded = false
    $scope.voteFormIsDisabled = false

  $scope.failure = (error) ->
    $scope.voteFormIsDisabled = false
    $scope.voteErrorMessages = error.messages

  $window.onresize = ->
    $scope.$apply()
