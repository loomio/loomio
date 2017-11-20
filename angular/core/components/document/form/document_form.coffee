angular.module('loomioApp').directive 'documentForm', (Records, SequenceService, FormService, KeyEventService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/form/document_form.html'
  controller: ($scope) ->

    SequenceService.applySequence $scope,
      steps: ['method', 'url', 'title']
      initialStep: if $scope.document.isNew() then 'method' else 'title'
      methodComplete: (_, method) -> $scope.document.method = method
      urlComplete:    (_, url)    -> $scope.document.url    = url
