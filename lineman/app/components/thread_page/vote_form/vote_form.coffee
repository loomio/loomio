angular.module('loomioApp').factory 'VoteForm', ->
  templateUrl: 'generated/components/thread_page/vote_form/vote_form.html'
  controller: ($scope, proposal, Records, CurrentUser, FlashService) ->
    $scope.proposal = proposal
    $scope.editing = false

    if myVote = $scope.proposal.lastVoteByUser(CurrentUser)
      $scope.vote = myVote.clone()
    else
      $scope.vote = Records.votes.initialize(proposal_id: proposal.id)

    $scope.changeVote = ->
      $scope.editing = true

    $scope.submit = ->
      $scope.vote.save().then ->
        FlashService.success 'vote_form.submitted_your_vote'
        $scope.editing = false
        $scope.vote = Records.votes.initialize({proposal_id: proposal.id})
        $scope.$close()

    $scope.yourLastVote = ->
      $scope.proposal.lastVoteByUser(CurrentUser)
