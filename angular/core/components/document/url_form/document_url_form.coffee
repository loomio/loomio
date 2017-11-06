angular.module('loomioApp').directive 'documentUrlForm', ($timeout, Records, FormService, AttachmentService, KeyEventService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/url_form/document_url_form.html'
  controller: ($scope) ->
    $scope.model = Records.discussions.build()
    $scope.model.url = $scope.document.url or ''

    $scope.$on 'attachmentUploaded', (_, attachment) ->
      $scope.document.url   = attachment.original
      $scope.document.title = $scope.document.title || attachment.filename

    $scope.toggleForm = ->
      $scope.document.method = switch $scope.document.method
        when 'url'  then 'file'
        when 'file' then 'url'

    $scope.next = ->
      $scope.document.url = $scope.model.url

    KeyEventService.submitOnEnter $scope, anyEnter: true
    AttachmentService.listenForPaste $scope
