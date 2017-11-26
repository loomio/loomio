angular.module('loomioApp').directive 'documentList', (Records, AbilityService, ModalService, DocumentModal) ->
  scope: {model: '='}
  replace: true
  templateUrl: 'generated/components/document/list/document_list.html'
  controller: ($scope) ->
    Records.documents.fetchByModel($scope.model) unless $scope.model.isNew()

    $scope.canEditDocuments = ->
      !$scope.model.isNew()
      $scope.model.constructor.singular == 'discussion' and
      AbilityService.canEditDocument($scope.model.group())

    $scope.edit = (doc) ->
      ModalService.open DocumentModal, doc: -> doc
