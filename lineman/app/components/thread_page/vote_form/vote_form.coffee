angular.module('loomioApp').directive 'voteForm', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/vote_form/vote_form.html'
  replace: true
  controller: ($scope, Records, CurrentUser, FormService, FlashService) ->
    currentUser = CurrentUser
    $scope.editing = false

    $scope.changeVote = ->
      $scope.editing = true

    $scope.vote = Records.votes.initialize({proposal_id: $scope.proposal.id})

    $scope.submit = ->
      $scope.vote.save().then ->
        FlashService.success 'vote_form.submitted_your_vote'
        $scope.editing = false
        $scope.vote = Records.votes.initialize({proposal_id: $scope.proposal.id})

    $scope.yourLastVote = ->
      $scope.proposal.lastVoteByUser(CurrentUser)

    $scope.cancel = ->
      $scope.editing = false
      $scope.vote.position = null

    $scope.positionOtherThan = (position) ->
      $scope.vote.position? && $scope.vote.position != position

    $scope.curatedVotes = ->
      positionValues = {yes: 0, abstain: 1, no: 2, block: 3}
      _.sortBy filteredVotes(), (vote) ->
        positionValues[vote.position]

    filteredVotes = ->
      return [] unless $scope.proposal
      _.filter $scope.proposal.uniqueVotes(), (vote) ->
        vote.authorId != currentUser.id
