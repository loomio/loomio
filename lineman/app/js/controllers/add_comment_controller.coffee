angular.module('loomioApp').controller 'AddCommentController', ($scope, CommentModel, CommentService) ->
  $scope.comment = new CommentModel(discussion_id: $scope.discussion.id)

  $scope.isExpanded = false

  $scope.expand = ->
    $scope.isExpanded = true

  $scope.collapseIfEmpty = ->
    if ($scope.comment.body.length == 0)
      $scope.isExpanded = false

  $scope.submit = () ->
    CommentService.create($scope.comment, $scope.success, $scope.error)

  $scope.$on 'showReplyToCommentForm', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id
    $scope.expand()

  $scope.success = ->
    $scope.comment = new CommentModel(discussion_id: $scope.discussion.id)
    $scope.isExpanded = false

  $scope.error = (error) ->
    console.log error
