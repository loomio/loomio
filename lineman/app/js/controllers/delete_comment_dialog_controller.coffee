angular.module('loomioApp').controller 'DeleteCommentDialogController', ($scope, $modalInstance, CommentModel, CommentService, comment) ->
  $scope.comment = comment

  success = ->
    $modalInstance.dismiss('success')

  failure = ->
    $modalInstance.dismiss('failure')

  $scope.ok = ->
    console.log 'dialog controller submit'
    # disable form.. maybe display a loading thing
    CommentService.delete(comment, success, failure)

  $scope.cancel = ->
    console.log 'cancel'
    $modalInstance.dismiss('cancel')

