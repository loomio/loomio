angular.module('loomioApp').controller 'ProposalController', ($scope, $window, ProposalService) ->
  $scope.voteFormIsDisabled = false
  $scope.voteFormIsExpanded = false

  if $scope.proposal?
    $scope.newVote = {position: null, statement: null, proposal_id: $scope.proposal.id}

  $scope.currentUserHasVoted = ->
    _.contains($scope.proposal.votes().map((vote) -> vote.user_id), $scope.currentUser.id)

  $scope.selectPosition = (position) ->
    $scope.newVote.position = position
    ## lets not expand it for the demo
    # $scope.voteFormIsExpanded = true
    ##faked
    console.log $scope.proposal, position
    newProposal = angular.copy($scope.proposal)
    key = position + '_votes_count'
    newProposal[key] += 1
    newProposal.votes_count +=1
    $scope.proposal = newProposal

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

  $scope.getScreenWidth = () ->
    $(window).width()

  $window.onresize = () ->
    $scope.$apply()
