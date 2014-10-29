angular.module('loomioApp').controller 'DashboardController', ($scope, UserAuthService) ->
  currentUser = UserAuthService.currentUser
