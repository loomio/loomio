angular.module('loomioApp').controller 'CommentController', ($scope, CommentService) ->
  $scope.comment = $scope.event.comment

  $scope.like = ->
    CommentService.like($scope.comment)

  $scope.unlike = ->
    CommentService.unlike($scope.comment)
