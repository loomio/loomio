angular.module('loomioApp').directive 'documentRemoveForm', ($timeout, Records, FormService) ->
  scope: {document: '='}
  templateUrl: 'generated/components/document/remove_form/document_remove_form.html'
  controller: ($scope) ->
    $scope.submit = FormService.submit $scope, $scope.document,
      submitFn: $scope.document.destroy
      flashSuccess: "document.flash.destroyed"
      # successCallback: -> $scope.menu.close()

    $scope.$on 'initializeRemoveDocument', (_, doc, $mdMenu) ->
      $scope.document = doc
      $scope.menu     = $mdMenu
      $timeout -> $scope.menu.open()
