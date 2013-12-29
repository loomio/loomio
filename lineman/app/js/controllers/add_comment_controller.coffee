angular.module('loomioApp').controller 'AddCommentController', ($scope, CommentService) ->
  $scope.isExpanded = false

  $scope.expand = ->
    $scope.isExpanded = true

  $scope.collapseIfEmpty = ->
    if ($scope.commentField.val().length == 0)
      $scope.isExpanded = false

  $scope.processForm = () ->
    CommentService.add($scope.newComment, $scope.discussion)

  $scope.$on 'startCommentReply', (event, originalComment) ->
    $scope.newComment.parent_id = originalComment.id
    $scope.expand()

