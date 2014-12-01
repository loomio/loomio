angular.module('loomioApp').controller 'VoteFormController', ($scope, Records, UserAuthService, FormService) ->
  $scope.vote = Records.votes.initialize({proposal_id: $scope.proposal.id})

  onSuccess = ->
    $scope.editing = false

  FormService.applyForm $scope, $scope.vote, onSuccess

  $scope.lastVote = ->
    $scope.proposal.lastVoteByUser(UserAuthService.currentUser)

  $scope.selectPosition = (position) ->
    $scope.vote.position = position

  $scope.cancel = ->
    $scope.editing = false

  $scope.edit = ->
    $scope.editing = true
