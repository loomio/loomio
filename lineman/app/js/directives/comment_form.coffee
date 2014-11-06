angular.module('loomioApp').directive 'commentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/comment_form.html'
  replace: true
  controller: 'CommentFormController'
  link: (scope, element, attrs) ->
