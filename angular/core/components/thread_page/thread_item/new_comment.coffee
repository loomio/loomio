angular.module('loomioApp').directive 'newComment', ($rootScope, Session, Records, AbilityService, ReactionService, TranslationService, ModalService, DeleteCommentForm, EditCommentForm, RevisionHistoryModal) ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/new_comment.html'
  replace: true
  controller: ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canAddComment($scope.eventable.discussion())
    ,
      name: 'reply_to_comment'
      icon: 'mdi-reply'
      canPerform: -> AbilityService.canRespondToComment($scope.eventable)
      perform: ->
        $rootScope.$broadcast 'closeReplyForms'
        $scope.$emit 'replyToCommentClicked', $scope.eventable
    ,
      name: 'edit_comment'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditComment($scope.eventable)
      perform:    -> ModalService.open EditCommentForm, comment: -> $scope.eventable
    ,
      name: 'translate_comment'
      icon: 'mdi-translate'
      canPerform: -> $scope.eventable.body && AbilityService.canTranslate($scope.eventable) && !$scope.translation
      perform:    -> TranslationService.inline($scope, $scope.eventable)
    ,
      name: 'show_history'
      icon: 'mdi-history'
      canPerform: -> $scope.eventable.edited()
      perform:    -> ModalService.open RevisionHistoryModal, model: -> $scope.eventable
    ,
      name: 'delete_comment'
      icon: 'mdi-delete'
      canPerform: -> AbilityService.canDeleteComment($scope.eventable)
      perform:    -> ModalService.open DeleteCommentForm, comment: -> $scope.eventable
    ]

    ReactionService.listenForReactions($scope, $scope.eventable)
    TranslationService.listenForTranslations($scope)
