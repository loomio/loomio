angular.module('loomioApp').controller 'DashboardPageController', ($scope, $location, UserAuthService) ->
  
  logout: ->
    UserAuthService.logout($scope.loggedOut)

  loggedOut: ->
    $location.path '/users/login'