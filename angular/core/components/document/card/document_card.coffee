angular.module('loomioApp').directive 'documentCard', (Records, LoadingService, ModalService, DocumentModal) ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/document/card/document_card.html'
  controller: ($scope) ->
    $scope.init = ->
      Records.documents.fetchByGroup($scope.group, null, per: 5)
    LoadingService.applyLoadingFunction $scope, 'init'
    $scope.init()

    $scope.addDocument = ->
      ModalService.open DocumentModal, doc: =>
        Records.documents.build
          modelId:   $scope.group.id
          modelType: 'Group'
