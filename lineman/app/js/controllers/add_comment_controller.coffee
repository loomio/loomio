angular.module('loomioApp').controller 'AddCommentController', ($scope, CommentModel, CommentService) ->
  $scope.comment = new CommentModel(discussion_id: $scope.discussion.id)

  $scope.isExpanded = false

  $scope.expand = ->
    $scope.isExpanded = true
    $scope.$broadcast 'expandCommentField'

  $scope.collapseIfEmpty = ->
    if ($scope.comment.body.length == 0)
      $scope.isExpanded = false

  $scope.$on 'showReplyToCommentForm', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id
    $scope.expand()

