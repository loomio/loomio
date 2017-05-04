angular.module('loomioApp').directive 'authSigninForm', (AuthService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ($scope) ->

    $scope.back = ->
      $scope.user.email = ''

    $scope.sendLoginLink = ->
      AuthService.sendLoginLink($scope.user.email)

    $scope.signIn = ->
      AuthService.signIn($scope.user.email, $scope.user.password)

    $scope.setPassword = ->
      AuthService.forgotPassword($scope.user.email)

    $scope.passwordFormShown = $scope.user.hasPassword
    $scope.showPasswordForm = ->
      $scope.passwordFormShown = true
