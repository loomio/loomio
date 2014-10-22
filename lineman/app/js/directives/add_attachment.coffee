angular.module('loomioApp').directive 'addAttachment', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/add_attachment.html'
  replace: true
  controller: 'AddAttachmentController'
  link: (scope, element, attrs) ->
