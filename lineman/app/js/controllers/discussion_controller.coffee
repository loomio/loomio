angular.module('loomioApp').controller 'DiscussionController', ($scope, discussion) ->
  $scope.currentUser = discussion.current_user
  $scope.discussion = discussion

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)
