angular.module('loomioApp').directive 'documentUrlForm', ($timeout, Records, FormService, DocumentService, KeyEventService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/url_form/document_url_form.html'
  controller: ($scope) ->
    $scope.model = Records.discussions.build()
    $scope.model.url = $scope.document.url or ''

    $scope.submit = ->
      $scope.$emit('nextStep', $scope.model.url)

    $scope.$on 'documentUploaded', (event, attachment) ->
      event.stopPropogation()
      $scope.document.title = $scope.document.title || attachment.filename
      $scope.$emit 'nextStep', attachment.original

    KeyEventService.submitOnEnter $scope, anyEnter: true
    DocumentService.listenForPaste $scope
