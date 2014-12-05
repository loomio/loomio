angular.module('loomioApp').directive 'editComment', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/discussion_page/comment/edit_comment.html'
  replace: true
  controller: 'EditCommentController'
  link: (scope, element, attrs) ->
