angular.module('loomioApp').controller 'DeleteCommentController', ($scope, $modalInstance, CommentService, FormService, comment) ->
  $scope.comment = comment

  FormService.applyForm $scope, CommentService.destroy, comment, $modalInstance
