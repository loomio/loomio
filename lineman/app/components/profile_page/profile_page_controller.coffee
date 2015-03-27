angular.module('loomioApp').controller 'ProfilePageController', ($scope, CurrentUser) ->
  $scope.user =  CurrentUser