angular.module('loomioApp').directive 'addReplyPanel', (AbilityService, ModalService, AuthModal) ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/add_reply_panel/add_reply_panel.html'
  controller: ($scope) ->
    $scope.$on 'replyToCommentClicked', (parentComment) ->
      $scope.parentComment = parentComment
      $scope.discussion = parentComment.discussion()
      $scope.show = true

    cancel: ->
      $scope.show = false
