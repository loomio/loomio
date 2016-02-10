angular.module('loomioApp').factory 'VoteForm', ->
  templateUrl: 'generated/components/thread_page/vote_form/vote_form.html'
  controller: ($scope, vote, CurrentUser, FlashService, FormService, KeyEventService) ->
    $scope.vote = vote.clone()
    $scope.editing = false

    $scope.$on 'modal.closing', (event) ->
      FormService.confirmDiscardChanges(event, $scope.vote)

    $scope.submit = FormService.submit $scope, $scope.vote,
      flashSuccess: 'vote_form.messages.created'

    $scope.yourLastVote = ->
      $scope.vote.proposal().lastVoteByUser(CurrentUser)

    $scope.$on 'emojiSelected', (event, emoji) ->
      $scope.vote.statement = $scope.vote.statement.trimRight() + " #{emoji} "

    KeyEventService.submitOnEnter $scope
