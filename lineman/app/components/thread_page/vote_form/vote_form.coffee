angular.module('loomioApp').factory 'VoteForm', ->
  templateUrl: 'generated/components/thread_page/vote_form/vote_form.html'
  controller: ($scope, proposal, position, Records, CurrentUser, FlashService) ->
    $scope.proposal = proposal
    $scope.editing = false

    $scope.changeVote = ->
      $scope.editing = true

    $scope.vote = Records.votes.initialize({proposal_id: proposal.id})

    if position
      $scope.vote.position = position

    $scope.submit = ->
      $scope.vote.save().then ->
        FlashService.success 'vote_form.submitted_your_vote'
        $scope.editing = false
        $scope.vote = Records.votes.initialize({proposal_id: proposal.id})
        $scope.$close()

    $scope.yourLastVote = ->
      $scope.proposal.lastVoteByUser(CurrentUser)
