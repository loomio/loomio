Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'
{applyLoadingFunction } = require 'shared/helpers/apply.coffee'
angular.module('loomioApp').directive 'revisionHistoryNav', ->
  scope: {model: '='}
  templateUrl: 'generated/components/revision_history/nav/revision_history_nav.html'
  controller:['$scope', ($scope) ->
    $scope.currentIndex = latestIndex = $scope.model.versionsCount - 1

    $scope.getVersion =->
      EventBus.emit $scope, 'versionFetching'
      Records.versions.fetchVersion($scope.model, $scope.currentIndex).then (data) ->
        version = Records.versions.find(data.versions[0].id)
        version.index = $scope.currentIndex
        EventBus.emit $scope, 'versionFetched', version
        Records.groups.findOrFetchById(version.changes.group_id[1]) if version.changes.group_id

    applyLoadingFunction $scope, 'getVersion'

    $scope.getVersion()

    $scope.isOldest =  ->
      $scope.currentIndex == 0

    $scope.isNewest = ->
      $scope.currentIndex == latestIndex

    $scope.setNextRevision = ->
      if !$scope.isNewest()
        $scope.currentIndex += 1;
        $scope.getVersion()

    $scope.setPreviousRevision = ->
      if ! $scope.isOldest()
        $scope.currentIndex -= 1;
        $scope.getVersion()

    $scope.setOldestRevision = ->
      $scope.currentIndex = 0
      $scope.getVersion()

    $scope.setLatestRevision = ->
      $scope.currentIndex = latestIndex
      $scope.getVersion()

  ]
