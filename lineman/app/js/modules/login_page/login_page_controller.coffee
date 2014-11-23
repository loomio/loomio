angular.module('loomioApp').controller 'LoginPageController', ($scope, $location, SessionService, SessionModel)->

  $scope.showErrors = false
  $scope.session = new SessionModel

  $scope.login = ->
    SessionService.create $scope.session, $scope.redirectToDashboard, $scope.failure

  $scope.redirectToDashboard = ->
    $location.path '/dashboard'

  $scope.failure = ->
    $scope.showErrors = true
