angular.module('loomioApp').directive 'commentForm', ->
  scope: {comment: '=?', discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/comment_form/comment_form.html'
  replace: true
  controller: 'CommentFormController'
