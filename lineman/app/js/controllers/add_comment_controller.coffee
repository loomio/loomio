angular.module('loomioApp').controller 'AddCommentController', ($scope, CommentModel, UserAuthService) ->
  $scope.comment = new CommentModel(discussion_id: $scope.discussion.id)
  $scope.currentUser = UserAuthService.currentUser


  $scope.$on 'showReplyToCommentForm', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id
    $scope.expand()
