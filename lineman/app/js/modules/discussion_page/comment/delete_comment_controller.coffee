angular.module('loomioApp').controller 'DeleteCommentController', ($scope, $modalInstance, FormService, comment) ->
  $scope.comment = comment

  onSubmit = (comment) ->
    comment.destroy()

  onSuccess = ->
    FlashService.success 'comment_form.destroy_comment'

  FormService.applyModalForm $scope, comment, $modalInstance, onSubmit

