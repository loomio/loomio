angular.module('loomioApp').directive 'attachmentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/attachment_form.html'
  replace: true
  controller: 'AttachmentFormController'
  link: (scope, element, attrs) ->
