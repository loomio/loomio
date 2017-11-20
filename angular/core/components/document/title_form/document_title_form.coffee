angular.module('loomioApp').directive 'documentTitleForm', (Records, FormService, KeyEventService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/title_form/document_title_form.html'
  controller: ($scope) ->
    $scope.submit = FormService.submit $scope, $scope.document,
      flashSuccess: "document.flash.success"
      successCallback: -> $scope.$emit 'nextStep'

    KeyEventService.submitOnEnter($scope, anyEnter: true)
