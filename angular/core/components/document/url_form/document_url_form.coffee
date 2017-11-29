angular.module('loomioApp').directive 'documentUrlForm', ($timeout, Records, FormService, DocumentService, KeyEventService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/url_form/document_url_form.html'
  controller: ($scope) ->
    $scope.model =
      url: $scope.document.url or ''

    $scope.submit = ->
      $scope.document.url = $scope.model.url
      $scope.$emit('nextStep', $scope.document)

    $scope.$on 'documentAdded', (event, doc) ->
      event.stopPropagation()
      $scope.$emit 'nextStep', doc

    KeyEventService.submitOnEnter $scope, anyEnter: true
    DocumentService.listenForPaste $scope
