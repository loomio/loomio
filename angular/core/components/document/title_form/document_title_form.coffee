angular.module('loomioApp').directive 'documentTitleForm', (Records, FormService, KeyEventService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/title_form/document_title_form.html'
  controller: ($scope) ->
    $scope.submit = FormService.submit $scope, $scope.document,
      successFlash: "document.flash.success"

    KeyEventService.submitOnEnter($scope, anyEnter: true)
