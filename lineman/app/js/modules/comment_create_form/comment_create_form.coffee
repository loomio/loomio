angular.module('loomioApp').directive 'commentCreateForm', ->
  scope: {comment: '=', discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/comment_create_form.html'
  replace: true
  controller: 'CommentCreateFormController'
  link: (scope, element, attrs) ->
