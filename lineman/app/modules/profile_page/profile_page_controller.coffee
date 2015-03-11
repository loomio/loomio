angular.module('loomioApp').controller 'ProfilePageController', ($scope, UserAuthService) ->
  $scope.user =  window.Loomio.currentUser