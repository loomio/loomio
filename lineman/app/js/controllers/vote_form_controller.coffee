angular.module('loomioApp').controller 'VoteFormController', ($scope, VoteModel, VoteService, UserAuthService) ->
  # buttons only
  # buttons and form
  # YourPosition

  #$scope.showForm = ->
    #$scope.vote.anyPosition()

  $scope.hasVoted = ->
    return false unless $scope.proposal
    $scope.proposal.userHasVoted(UserAuthService.currentUser)

  $scope.isEditing = false

  $scope.changePosition = ->
    $scope.vote = new VoteModel(proposal_id: $scope.proposal.id)
    $scope.isEditing = true


  currentOrNewVote = ->
    return false unless $scope.proposal
    if $scope.hasVoted()
      $scope.proposal.lastVoteByUser(UserAuthService.currentUser)
    else
      new VoteModel(proposal_id: $scope.proposal.id)

  $scope.vote = currentOrNewVote()
  console.log $scope.vote

  $scope.selectPosition = (position) ->
    $scope.vote.position = position
    console.log 'position change to: '+$scope.vote.positionVerb()
    $scope.showForm = true

  $scope.submit = ->
    $scope.isDisabled = true
    VoteService.create($scope.vote, saveSuccess, saveError)

  $scope.cancel = ($event) ->
    $scope.isEditing = false
    $scope.vote = currentOrNewVote()
    $event.preventDefault();
    #$modalInstance.dismiss('cancel');

  saveSuccess = ->
    $scope.isDisabled = false
    $scope.isEditing = false
    #$modalInstance.close();

  saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

