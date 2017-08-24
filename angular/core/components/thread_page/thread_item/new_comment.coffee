angular.module('loomioApp').directive 'newComment', ($rootScope, Session, Records, AbilityService, ReactionService, TranslationService, ModalService, DeleteCommentForm, EditCommentForm, RevisionHistoryModal) ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/new_comment.html'
  replace: true
  controller: ($scope) ->
    $scope.editComment = ->
      ModalService.open EditCommentForm, comment: -> $scope.eventable

    $scope.deleteComment = ->
      ModalService.open DeleteCommentForm, comment: -> $scope.eventable

    $scope.showContextMenu = ->
      $scope.canEditComment($scope.eventable) or $scope.canDeleteComment($scope.eventable)

    $scope.canEditComment = ->
      AbilityService.canEditComment($scope.eventable)

    $scope.canDeleteComment = ->
      AbilityService.canDeleteComment($scope.eventable)

    $scope.showCommentActions = ->
      AbilityService.canRespondToComment($scope.eventable)

    $scope.reply = ->
      $rootScope.$broadcast 'replyToCommentClicked', $scope.eventable

    $scope.showRevisionHistory = ->
      ModalService.open RevisionHistoryModal, model: => $scope.eventable

    ReactionService.listenForReactions($scope, $scope.eventable)
    TranslationService.listenForTranslations($scope)
