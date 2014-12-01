angular.module('loomioApp').controller 'VoteFormController', ($scope, Records, VoteService, UserAuthService, FormService) ->
  $scope.vote = Records.votes.new({proposal_id: $scope.proposal.id})

  FormService.applyForm $scope, VoteService.save, $scope.vote

  $scope.lastVote = ->
    $scope.proposal.lastVoteByUser(UserAuthService.currentUser)

  $scope.selectPosition = (position) ->
    $scope.vote.position = position

  $scope.edit = -> 
    $scope.editing = true

  $scope.successCallback = -> 
    $scope.editing = false

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $scope.editing = false