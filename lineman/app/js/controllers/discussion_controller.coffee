angular.module('loomioApp').controller 'DiscussionController', ($scope, discussion) ->
  $scope.currentUser = discussion.current_user
  $scope.discussion = discussion
  $scope.newComment = {}
  $scope.newComment.discussion_id = discussion.id

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)
