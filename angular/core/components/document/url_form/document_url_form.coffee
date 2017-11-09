angular.module('loomioApp').directive 'documentUrlForm', ($timeout, Records, FormService, AttachmentService, KeyEventService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/url_form/document_url_form.html'
  controller: ($scope) ->
    $scope.model = Records.discussions.build()
    $scope.model.url = $scope.document.url or ''

    $scope.$on 'attachmentUploaded', (_, attachment) ->
      $scope.document.title = $scope.document.title || attachment.filename
      $scope.$emit 'nextStep', attachment.original

    KeyEventService.submitOnEnter $scope, anyEnter: true
    AttachmentService.listenForPaste $scope
