angular.module('loomioApp').controller 'VoteFormController', ($scope, Records, VoteService, UserAuthService, FormService) ->
  $scope.vote = Records.votes.new({proposal_id: $scope.proposal.id})

  FormService.applyForm $scope, VoteService.save, $scope.vote

  $scope.lastVote = ->
    $scope.proposal.lastVoteByUser(UserAuthService.currentUser)

  $scope.changePosition = ->
    $scope.editing = true

  $scope.selectPosition = (position) ->
    $scope.vote.position = position
