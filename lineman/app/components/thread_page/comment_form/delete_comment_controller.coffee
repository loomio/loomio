angular.module('loomioApp').controller 'DeleteCommentController', ($scope, $modalInstance, comment) ->
  $scope.comment = comment

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

  $scope.delete = ->
    $scope.comment.destroy().then ->
      $modalInstance.dismiss('success')
