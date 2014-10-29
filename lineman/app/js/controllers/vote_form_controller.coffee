angular.module('loomioApp').controller 'VoteFormController', ($scope, VoteModel, VoteService, UserAuthService) ->
  $scope.lastVote = null
  $scope.newVote = new VoteModel

  if $scope.proposal
    $scope.lastVote = $scope.proposal.lastVoteByUser(UserAuthService.currentUser)

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
    $scope.lastVote = $scope.newVote
    $scope.newVote = new VoteModel(proposal_id: $scope.proposal.id)
    $scope.isDisabled = false
    $scope.editing = false
    $scope.$emit('newVote')

  saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

