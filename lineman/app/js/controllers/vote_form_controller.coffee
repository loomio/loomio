angular.module('loomioApp').controller 'VoteFormController', ($scope, Records, UserAuthService, FormService) ->
  $scope.vote = Records.votes.initialize({proposal_id: $scope.proposal.id})

  FormService.applyForm $scope, Records.votes.save, $scope.vote

  $scope.lastVote = ->
    $scope.proposal.lastVoteByUser(UserAuthService.currentUser)

  $scope.changePosition = ->
    $scope.editing = true

  $scope.selectPosition = (position) ->
    $scope.vote.position = position

  $scope.cancel = ->
    $scope.editing = false
