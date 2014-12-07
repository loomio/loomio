angular.module('loomioApp').directive 'editComment', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/comment_form/edit_comment.html'
  replace: true
  controller: 'EditCommentController'
  link: (scope, element, attrs) ->
