angular.module('loomioApp').directive 'attachmentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/comment_form/attachment_form.html'
  replace: true
  controller: 'AttachmentFormController'
  link: (scope, element, attrs) ->
