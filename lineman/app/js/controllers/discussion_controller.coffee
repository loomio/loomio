angular.module('loomioApp').controller 'DiscussionController', ($scope, discussion) ->
  $scope.currentUser = discussion.current_user
  $scope.discussion = discussion
  $scope.newComment = {}
  $scope.newComment.discussion_id = discussion.id
  $scope.$on 'startCommentReply', (event, originalComment) ->
    $scope.$broadcast('startCommentReply', originalComment)
