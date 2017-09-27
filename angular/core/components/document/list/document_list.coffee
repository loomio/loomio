angular.module('loomioApp').directive 'documentList', (Records, AbilityService) ->
  scope: {model: '='}
  replace: true
  templateUrl: 'generated/components/document/list/document_list.html'
  controller: ($scope) ->
    Records.documents.fetch
      params:
        "#{$scope.model.constructor.singular}_id": $scope.model.id

    $scope.canEditDocuments = ->
      AbilityService.canEditDocument($scope.model.group())
