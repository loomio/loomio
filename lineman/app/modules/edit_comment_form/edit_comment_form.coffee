angular.module('loomioApp').directive 'editCommentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/edit_comment_form.html'
  replace: true
  controller: 'EditCommentFormController'
  link: (scope, element, attrs) ->
