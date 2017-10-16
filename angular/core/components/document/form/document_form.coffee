angular.module('loomioApp').directive 'documentForm', (Records, FormService, KeyEventService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/form/document_form.html'
  controller: ($scope) ->
    $scope.currentStep = 'url'

    $scope.$on 'urlSaved', ->
      $scope.currentStep = 'title'
    $scope.$on 'backFromTitle', ->
      $scope.document.title = $scope.document.url = ''
      $scope.currentStep    = 'url'
