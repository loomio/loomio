angular.module('loomioApp').directive 'authSignupForm', ($location, AppConfig, AuthService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ($scope) ->
    $scope.user.name = $scope.name = AppConfig.pendingIdentity.name or $location.search().invitation_name
    $scope.helperBot =
      constructor: {singular: 'user'}
      avatarKind: 'uploaded'
      avatarUrl:  '/img/mascot.png'

    $scope.back = ->
      $scope.user.email = ''

    $scope.signUp = ->
      AuthService.signUp($scope.user.email, $scope.user.name)
