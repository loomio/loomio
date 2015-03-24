angular.module('loomioApp').controller 'NotificationVolumeController', ($scope) ->

  $scope.changeVolume = ->
    $scope.model.volume = $scope.volume
    $scope.model.save()

  return
