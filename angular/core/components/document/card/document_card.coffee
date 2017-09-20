angular.module('loomioApp').directive 'documentCard', (Records, AbilityService, ModalService, DocumentModal) ->
  scope: {model: '='}
  replace: true
  templateUrl: 'generated/components/document/card/document_card.html'
  controller: ($scope) ->

    Records.documents.fetch
      params:
        "#{$scope.model.constructor.singular}_id": $scope.model.id

    $scope.canAddDocuments = ->
      AbilityService.canAddDocuments($scope.model.group())

    $scope.addDocument = ->
      ModalService.open DocumentModal, model: -> $scope.model
