angular.module('loomioApp').directive 'addReplyPanel', (Session, ScrollService, AbilityService, ModalService, AuthModal) ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/add_reply_panel/add_reply_panel.html'
  controller: ($scope) ->
    $scope.actor = Session.user()

    $scope.close = ->
      $scope.show = false

    $scope.$on 'commentSaved', $scope.close
    $scope.$on 'closeReplyForms', $scope.close

    $scope.$on 'showReplyForm', (e, parentComment) ->
      $scope.parentComment = parentComment
      $scope.discussion = parentComment.discussion()
      $scope.show = true

      ScrollService.scrollTo('.add-reply-panel textarea', {bottom: true, offset: 200})
