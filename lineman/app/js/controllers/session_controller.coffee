angular.module('loomioApp').controller 'SessionController', ($scope, UserAuthService)->

  $scope.credentials =
    user:
      email: ''
      password: ''
      remember_me: ''

  $scope.login = ->
    UserAuthService.login($scope.credentials)

  $scope.logout = ->
    UserAuthService.logout()