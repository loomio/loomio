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
        FlashService.good 'vote_form.submitted_your_vote'
        $scope.editing = false
        $scope.vote = Records.votes.initialize({proposal_id: $scope.proposal.id})

    $scope.yourLastVote = ->
      $scope.proposal.lastVoteByUser(CurrentUser)

    $scope.cancel = ->
      $scope.editing = false
      #$scope.vote.position = null
