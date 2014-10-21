angular.module('loomioApp').controller 'ProposalController', ($scope, $window, ProposalService) ->
  $scope.voteFormIsDisabled = false
  $scope.voteFormIsExpanded = false

  if $scope.proposal?
    $scope.newVote = {position: null, statement: null, proposalId: $scope.proposal.id}

  $scope.currentUserVote = ->
    if $scope.proposal?
      index = $scope.proposal.votes().map((vote) -> vote.author_id).indexOf($scope.$parent.currentUser.user.id)
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
