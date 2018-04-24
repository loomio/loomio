Records           = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'RevisionHistoryModal', ->
  templateUrl: 'generated/components/thread_page/revision_history_modal/revision_history_modal.html'
  controller:['$scope', 'model', ($scope,  model) ->
    $scope.model = model
    $scope.type = model.constructor.singular
    $scope.currentIndex = model.versionsCount - 1

    $scope.getVersion = () ->
      Records.versions.fetchVersion($scope.model, $scope.currentIndex).then (data) ->
        $scope.version = Records.versions.find(data.versions[0].id)

    $scope.isOldest = ->
      $scope.currentIndex == 0;

    $scope.isNewest = ->
      $scope.currentIndex == model.versionsCount - 1

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
      $scope.currentIndex = model.versionsCount - 1
      $scope.getVersion()

    $scope.initScope = do ->
      $scope.title =  _.capitalize $scope.type + " Revision History"
      $scope.currentIndex = 0;
      $scope.setLatestRevision();
  ]
