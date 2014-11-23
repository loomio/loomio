angular.module('loomioApp').directive 'newComment', ->
  scope: {event: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/new_comment.html'
  replace: true
  controller: 'NewCommentController'
  link: (scope, element, attrs) ->
