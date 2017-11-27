angular.module('loomioApp').factory 'EditCommentForm', ->
  templateUrl: 'generated/components/thread_page/comment_form/edit_comment_form.html'
  controller: ($scope, comment, FormService, EmojiService, MentionService) ->
    $scope.comment = comment.clone()

    $scope.submit = FormService.submit $scope, $scope.comment,
      flashSuccess: 'comment_form.messages.updated'

    $scope.bodySelector = '.edit-comment-form__comment-field'
    EmojiService.listen $scope, $scope.comment, 'body', $scope.bodySelector
    MentionService.applyMentions $scope, $scope.comment
