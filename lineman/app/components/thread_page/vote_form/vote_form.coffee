angular.module('loomioApp').factory 'VoteForm', ->
  templateUrl: 'generated/components/thread_page/vote_form/vote_form.html'
  controller: ($scope, vote, CurrentUser, FlashService) ->
    $scope.vote = vote
    $scope.editing = false

    $scope.changeVote = ->
      $scope.editing = true

    $scope.submit = ->
      $scope.vote.save().then ->
        FlashService.success 'vote_form.messages.created'
        $scope.editing = false
        $scope.$close()

    $scope.yourLastVote = ->
      $scope.vote.proposal().lastVoteByUser(CurrentUser)
