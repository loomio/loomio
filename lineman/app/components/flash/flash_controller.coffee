angular.module('loomioApp').controller 'FlashController', ($scope, FlashService) ->
  $scope.flash = FlashService.currentFlash

  $scope.modalIsVisible = ->
    angular.element('.modal').hasClass('in')

  $scope.display = ->
    $scope.flash.message and ($scope.modal == $scope.modalIsVisible())

  $scope.dismiss = ->
    FlashService.clear()
