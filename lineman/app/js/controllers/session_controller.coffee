angular.module('loomioApp').controller 'SessionController', ($scope, UserAuthService)->

  $scope.credentials =
    email: ''
    password: ''

  $scope.login = ->
    UserAuthService.login($scope.credentials)

  $scope.logout = ->
    UserAuthService.logout()