angular.module('loomioApp').directive 'documentList', (Records, AbilityService, ModalService, DocumentModal, ConfirmModal) ->
  scope: {model: '=', showEdit: '=?'}
  replace: true
  templateUrl: 'generated/components/document/list/document_list.html'
  controller: ($scope) ->
    Records.documents.fetchByModel($scope.model) unless $scope.model.isNew()

    $scope.showTitle = ->
      ($scope.model.showDocumentTitle or $scope.showEdit) and
      ($scope.model.hasDocuments() or $scope.placeholder)

    $scope.edit = (doc, $mdMenu) ->
      $scope.$broadcast 'initializeDocument', doc, $mdMenu
