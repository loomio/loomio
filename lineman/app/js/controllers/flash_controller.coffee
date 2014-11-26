angular.module('loomioApp').controller 'FlashController', ($scope, FlashService) ->
  $scope.flash = FlashService.currentFlash

  $scope.dismiss = ->
    FlashService.clear()
