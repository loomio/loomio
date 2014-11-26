angular.module('loomioApp').controller 'NavbarSearchController', ($scope, UserAuthService) ->
  
  $scope.availableGroups = ->
    UserAuthService.currentUser.groups() if UserAuthService.currentUser?