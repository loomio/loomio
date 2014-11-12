angular.module('loomioApp').controller 'NavbarController', ($scope) ->
  $scope.inboxIsOpen = false

  $scope.toggled = (open) ->
    $scope.inboxIsOpen = open

