angular.module('loomioApp').controller 'DeleteCommentController', ($scope, $modalInstance, CommentService, FormService, comment) ->
  $scope.comment = comment

  $scope.successMessage = 'comment_form.destroy_comment'
  FormService.applyForm $scope, CommentService.destroy, comment, $modalInstance
