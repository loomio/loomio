angular.module('loomioApp').factory 'EditCommentForm', ->
  templateUrl: 'generated/components/thread_page/comment_form/edit_comment_form.html'
  controller: ($scope, comment, FormService, EmojiService) ->
    $scope.comment = comment.clone()

    $scope.submit = FormService.submit $scope, $scope.comment,
      flashSuccess: 'comment_form.messages.updated'
