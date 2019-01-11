Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'

{ applyLoadingFunction } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').factory 'RevisionHistoryModal', ->
  template: require('./revision_history_modal.haml')
  controller:['$scope', 'model', ($scope,  model) ->
    $scope.model = model
    $scope.type = model.constructor.singular

    EventBus.listen $scope, 'versionFetching',             -> $scope.version = null
    EventBus.listen $scope, 'versionFetched', (_, version) ->
      $scope.version = version
  ]
