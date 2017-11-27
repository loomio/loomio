angular.module('loomioApp').directive 'documentList', (Records, AbilityService, ModalService, DocumentModal, ConfirmModal) ->
  scope: {model: '=', showEdit: '=?'}
  replace: true
  templateUrl: 'generated/components/document/list/document_list.html'
  controller: ($scope) ->
    Records.documents.fetchByModel($scope.model) unless $scope.model.isNew()

    $scope.edit = (doc, $mdMenu) ->
      $scope.$broadcast 'initializeDocument', doc, $mdMenu
