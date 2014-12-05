angular.module('loomioApp').directive 'editComment', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/discussion_page/comments/edit_comment.html'
  replace: true
  controller: 'EditCommentController'
  link: (scope, element, attrs) ->
