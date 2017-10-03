angular.module('loomioApp').directive 'documentList', (Records) ->
  scope: {model: '='}
  replace: true
  templateUrl: 'generated/components/document/list/document_list.html'
  controller: ($scope) ->
    Records.documents.fetchByModel($scope.model)

    $scope.canEditDocuments = ->
      AbilityService.canEditDocument($scope.model.group())
