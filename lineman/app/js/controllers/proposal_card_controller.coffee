angular.module('loomioApp').controller 'ProposalCardController', ($scope, $modal, ProposalService, UserAuthService, VoteModel) ->

  $scope.currentUser = UserAuthService.currentUser

  openVoteForm = (vote) ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/vote_form.html'
      controller: 'VoteFormController'
      resolve:
        vote: -> vote

  $scope.castVote = (position) ->
    vote = new VoteModel(proposal_id: $scope.proposal.id, position: position)
    openVoteForm(vote)

  $scope.currentUserHasVoted = ->
    $scope.proposal.userHasVoted(UserAuthService.currentUser)

  $scope.lastVoteByCurrentUser = ->
    $scope.proposal.lastVoteByUser(UserAuthService.currentUser)

  #$scope.submitVote = ->
    #$scope.voteFormIsDisabled = true
    #ProposalService.saveVote($scope.newVote, $scope.success, $scope.failure)

