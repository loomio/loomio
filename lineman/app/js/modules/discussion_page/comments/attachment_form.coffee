angular.module('loomioApp').directive 'attachmentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/discussion_page/comments/attachment_form.html'
  replace: true
  controller: 'AttachmentFormController'
  link: (scope, element, attrs) ->
