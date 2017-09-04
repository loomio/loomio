angular.module('loomioApp').directive 'newComment', ($rootScope, Session, Records, AbilityService, ReactionService, TranslationService, ModalService, DeleteCommentForm, EditCommentForm, RevisionHistoryModal) ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/new_comment.html'
  replace: true
  controller: ($scope) ->
    $scope.showRevisionHistory = ->
      ModalService.open RevisionHistoryModal, model: => $scope.eventable

    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canAddComment($scope.eventable.discussion())
    ,
      name: 'reply_to_comment'
      icon: 'reply'
      canPerform: -> AbilityService.canRespondToComment($scope.eventable)
      perform:    -> $rootScope.$broadcast 'replyToCommentClicked', $scope.eventable
    ,
      name: 'edit_comment'
      icon: 'edit'
      canPerform: -> AbilityService.canEditComment($scope.eventable)
      perform:    -> ModalService.open EditCommentForm, comment: -> $scope.eventable
    ,
      name: 'translate_comment'
      icon: 'translate'
      canPerform: -> AbilityService.canTranslate($scope.eventable)
      perform:    ->
    ,
      name: 'delete_comment'
      icon: 'delete'
      canPerform: -> AbilityService.canDeleteComment($scope.eventable)
      perform:    -> ModalService.open DeleteCommentForm, comment: -> $scope.eventable
    ]

    ReactionService.listenForReactions($scope, $scope.eventable)
    TranslationService.listenForTranslations($scope)
