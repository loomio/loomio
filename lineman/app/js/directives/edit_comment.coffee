angular.module('loomioApp').directive 'editComment', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/edit_comment.html'
  replace: true
  controller: 'EditCommentController'
  link: (scope, element, attrs) ->
