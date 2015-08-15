angular.module('loomioApp').factory 'VoteForm', ->
  templateUrl: 'generated/components/thread_page/vote_form/vote_form.html'
  controller: ($scope, vote, CurrentUser, FlashService, FormService, KeyEventService) ->
    $scope.vote = vote.clone()
    $scope.editing = false

    $scope.$on 'modal.closing', (event) ->
      FormService.confirmDiscardChanges(event, $scope.vote)

    $scope.submit = ->
      $scope.vote.save().then ->
        FlashService.success 'vote_form.messages.created'
        $scope.editing = false
        $scope.$close()

    $scope.yourLastVote = ->
      $scope.vote.proposal().lastVoteByUser(CurrentUser)

    KeyEventService.submitOnEnter $scope
