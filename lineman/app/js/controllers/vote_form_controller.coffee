angular.module('loomioApp').controller 'VoteFormController', ($scope, Records, UserAuthService, FormService) ->
  $scope.vote = Records.votes.initialize({proposal_id: $scope.proposal.id})

  FormService.applyForm $scope, Records.votes.save, $scope.vote

  $scope.lastVote = ->
    $scope.proposal.lastVoteByUser(UserAuthService.currentUser)

  $scope.selectPosition = (position) ->
    $scope.vote.position = position

  $scope.cancel = ->
    $scope.editing = false

  $scope.edit = ->
    $scope.editing = true

  $scope.onSuccess = ->
    $scope.editing = false

  $scope.cancel = ($event) ->
    $scope.editing = false
