angular.module('loomioApp').controller 'ProposalController', ($scope, ProposalService) ->
  $scope.voteFormIsDisabled = false
  $scope.voteFormIsExpanded = false

  if $scope.proposal?
    $scope.newVote = {position: null, statement: null, proposal_id: $scope.proposal.id}

  $scope.selectPosition = (position) ->
    $scope.newVote.position = position
    $scope.voteFormIsExpanded = true

  $scope.submitVote = ->
    $scope.voteFormIsDisabled = true
    ProposalService.saveVote($scope.newVote, $scope.saveVoteSuccess, $scope.saveVoteError)

  $scope.saveVoteSuccess = (event) ->
    $scope.voteFormIsExpanded = false
    $scope.voteFormIsDisabled = false
    $scope.currentUserVote = event.eventable

  $scope.saveVoteError = (error) ->
    $scope.voteFormIsDisabled = false
    $scope.voteErrorMessages = error.messages
