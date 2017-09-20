angular.module('loomioApp').directive 'documentCard', (ModalService, DocumentModal) ->
  scope: {model: '='}
  templateUrl: 'generated/components/document/card/document_card.html'
  controller: ($scope) ->
    $scope.addDocument = ->
      ModalService.open DocumentModal, model: -> $scope.model
