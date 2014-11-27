angular.module('loomioApp').controller 'FlashController', ($scope, FlashService) ->
  $scope.flash = FlashService.currentFlash

  modalIsVisible = ->
    angular.element('.modal').hasClass('in')

  $scope.display = ->
    $scope.flash.message and ($scope.modal == modalIsVisible())

  $scope.dismiss = ->
    FlashService.clear()
