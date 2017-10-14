angular.module('loomioApp').directive 'addCommentPanel', (AbilityService, ModalService, AuthModal) ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/add_comment_panel/add_comment_panel.html'
  replace: true
  controller: ($scope) ->
    $scope.showCommentForm = ->
      AbilityService.canAddComment($scope.discussion)

    $scope.isLoggedIn = AbilityService.isLoggedIn
    $scope.signIn = -> ModalService.open AuthModal
