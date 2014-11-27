angular.module('loomioApp').controller 'VoteFormController', ($scope, Records, VoteService, UserAuthService) ->
  $scope.newVote = Records.votes.new

  $scope.lastVote = ->
    $scope.proposal.lastVoteByUser(UserAuthService.currentUser)

  $scope.editing = false

  $scope.changePosition = ->
    $scope.editing = true

  $scope.selectPosition = (position) ->
    $scope.newVote.position = position

  $scope.submit = ->
    $scope.isDisabled = true
    $scope.newVote.proposalId = $scope.proposal.id
    VoteService.create($scope.newVote, saveSuccess, saveError)

  $scope.cancel = ($event) ->
    $scope.editing = false
    $event.preventDefault();

  saveSuccess = ->
    $scope.newVote = Records.votes.new(proposal_id: $scope.proposal.id)
    $scope.isDisabled = false
    $scope.editing = false
    $scope.$emit('newVote')

  saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

