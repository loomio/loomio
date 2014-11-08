angular.module('loomioApp').controller 'DeleteCommentDialogController', ($scope, $modalInstance, CommentModel, CommentService, comment) ->
  $scope.comment = comment

  success = ->
    $modalInstance.dismiss('success')

  failure = ->
    $modalInstance.dismiss('failure')

  $scope.submit = ->
    CommentService.delete(comment, success, failure)

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

