angular.module('loomioApp').controller 'DashboardController', ($scope, $location, UserAuthService) ->
  
  logout: ->
    UserAuthService.logout($scope.loggedOut)

  loggedOut: ->
    $location.path '/users/login'