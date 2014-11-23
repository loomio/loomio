angular.module('loomioApp').controller 'EditCommentFormController', ($scope, $modalInstance, CommentModel, CommentService, comment) ->
  $scope.comment = comment

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

  $scope.$on 'commentSaveSuccess', ->
    $modalInstance.dismiss('success')
