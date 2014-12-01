angular.module('loomioApp').controller 'ProfilePageController', ($scope, UserAuthService) ->
  $scope.user =  UserAuthService.currentUser