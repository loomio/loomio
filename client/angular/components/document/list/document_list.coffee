Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'documentList', ->
  scope: {model: '=', showEdit: '=?', hidePreview: '=?'}
  replace: true
  templateUrl: 'generated/components/document/list/document_list.html'
  controller: ($scope) ->
    Records.documents.fetchByModel($scope.model) unless $scope.model.isNew()

    $scope.showTitle = ->
      ($scope.model.showDocumentTitle or $scope.showEdit) and
      ($scope.model.hasDocuments() or $scope.placeholder)

    $scope.edit = (doc, $mdMenu) ->
      $scope.$broadcast 'initializeDocument', doc, $mdMenu
