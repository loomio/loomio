angular.module('loomioApp').directive 'commentEditFormController', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/comment_edit_form_controller.html'
  replace: true
  controller: 'CommentEditFormController'
  link: (scope, element, attrs) ->
