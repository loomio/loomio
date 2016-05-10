angular.module('loomioApp').factory 'VoteForm', ->
  templateUrl: 'generated/components/thread_page/vote_form/vote_form.html'
  controller: ($scope, vote, Session, FlashService, FormService, KeyEventService, EmojiService) ->
    $scope.vote = vote.clone()
    $scope.editing = false

    $scope.$on 'modal.closing', (event) ->
      FormService.confirmDiscardChanges(event, $scope.vote)

    $scope.submit = FormService.submit $scope, $scope.vote,
      flashSuccess: 'vote_form.messages.created'
      successEvent: 'voteCreated'

    $scope.yourLastVote = ->
      $scope.vote.proposal().lastVoteByUser(Session.user())

    $scope.statementSelector = '.vote-form__statement-field'
    EmojiService.listen $scope, $scope.vote, 'statement', $scope.statementSelector

    KeyEventService.submitOnEnter $scope
