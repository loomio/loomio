angular.module('loomioApp').controller 'AddCommentController', ($scope, Records) ->
  $scope.comment = Records.comments.initialize(discussion_id: $scope.discussion.id)
  $scope.currentUser = UserAuthService.currentUser

  $scope.$on 'showReplyToCommentForm', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id
    $scope.expand()
