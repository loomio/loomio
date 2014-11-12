angular.module('loomioApp').controller 'SessionController', ($scope, $location, SessionService, SessionModel)->

  $scope.showErrors = false
  $scope.session = new SessionModel()

  $scope.login = ->
    SessionService.create $scope.session, $scope.redirectToDashboard, $scope.failure

  $scope.redirectToDashboard = ->
    $location.path '/dashboard'

  $scope.failure = ->
    $scope.showErrors = true
