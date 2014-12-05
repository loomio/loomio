angular.module('loomioApp').directive 'commentForm', ->
  scope: {comment: '=?', discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/discussion_page/comments/comment_form.html'
  replace: true
  controller: 'CommentFormController'
