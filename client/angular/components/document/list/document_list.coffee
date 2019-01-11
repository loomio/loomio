Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'

angular.module('loomioApp').directive 'documentList', ->
  scope: {model: '=', showEdit: '=?', hidePreview: '=?', hideDate: '=?', skipFetch: '=?'}
  replace: true
  template: require('./document_list.haml')
  controller: ['$scope', ($scope) ->
    Records.documents.fetchByModel($scope.model) unless $scope.model.isNew() or $scope.skipFetch

    $scope.showTitle = ->
      ($scope.model.showDocumentTitle or $scope.showEdit) and
      ($scope.model.hasDocuments() or $scope.placeholder)

    $scope.edit = (doc, $mdMenu) ->
      EventBus.broadcast $scope, 'initializeDocument', doc, $mdMenu
  ]
