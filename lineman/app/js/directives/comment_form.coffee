angular.module('loomioApp').directive 'commentForm', ->
  scope: {comment: '=', discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/comment_form.html'
  replace: true
  controller: 'CommentFormController'
