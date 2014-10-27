angular.module('loomioApp').controller 'VoteFormController', ($scope, VoteModel, VoteService, UserAuthService) ->
  # if lastVote and !editing
    # form mode
    # always a new vote
    # buttons only
    #   click position to open form. cancel closes form
    # buttons and form
  
  # display mode
    # show lastVote if there is one

  $scope.lastVote = null

  if $scope.proposal
    $scope.lastVote = $scope.proposal.lastVoteByUser(UserAuthService.currentUser)

  $scope.editing = false

  $scope.changePosition = ->
    $scope.editing = true

  $scope.newVote = new VoteModel(proposal_id: $scope.proposal.id)

  $scope.selectPosition = (position) ->
    $scope.newVote.position = position

  $scope.submit = ->
    $scope.isDisabled = true
    VoteService.create($scope.newVote, saveSuccess, saveError)

  $scope.cancel = ($event) ->
    $scope.editing = false
    #$scope.vote = currentOrNewVote()
    $event.preventDefault();
    #$modalInstance.dismiss('cancel');

  saveSuccess = ->
    $scope.lastVote = $scope.newVote
    $scope.newVote = new VoteModel(proposal_id: $scope.proposal.id)
    $scope.isDisabled = false
    $scope.editing = false
    #$modalInstance.close();

  saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

