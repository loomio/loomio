angular.module('loomioApp').directive 'addComment', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/add_comment.html'
  replace: true
  controller: 'AddCommentController'
  link: (scope, element, attrs) ->
