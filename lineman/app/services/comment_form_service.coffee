angular.module('loomioApp').factory 'CommentFormService', ($modal, Records) ->
  new class CommentFormService
    openEditCommentModal: (comment) ->
      $modal.open
        templateUrl: 'generated/modules/discussion_page/comment_form/edit_comment.html',
        controller: 'EditCommentController',
        resolve:
          comment: -> Records.comments.find(comment.id)

    openDeleteCommentModal: (comment) ->
      $modal.open
        templateUrl: 'generated/modules/discussion_page/comment_form/delete_comment.html'
        controller: 'DeleteCommentController'
        resolve:
          comment: -> Records.comments.find(comment.id)
