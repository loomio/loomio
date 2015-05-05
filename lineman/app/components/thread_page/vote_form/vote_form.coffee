angular.module('loomioApp').directive 'voteForm', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/vote_form/vote_form.html'
  replace: true
  controller: ($scope, Records, CurrentUser, FormService, FlashService) ->
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

    sortValueForVote = (vote) ->
      positionValues = {yes: 1, abstain: 2, no: 3, block: 4}
      if $scope.voteIsMine(vote)
        0
      else
        positionValues[vote.position]

    $scope.curatedVotes = ->
      _.sortBy $scope.proposal.uniqueVotes(), (vote) ->
        sortValueForVote(vote)

    $scope.voteIsMine = (vote) ->
      vote.authorId == CurrentUser.id