angular.module('loomioApp').directive 'authSigninForm', (AuthService, KeyEventService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ($scope) ->

    $scope.back = ->
      $scope.user.emailStatus = null

    $scope.signIn = ->
      AuthService.signIn($scope.user)

    $scope.sendLoginLink = ->
      AuthService.sendLoginLink($scope.user)

    $scope.submit = ->
      if $scope.user.hasPassword
        $scope.signIn()
      else
        $scope.sendLoginLink()

    $scope.setPassword = ->
      AuthService.forgotPassword($scope.user)

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.submit
