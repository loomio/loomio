angular.module('loomioApp').directive 'authSigninForm', (AuthService, KeyEventService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ($scope) ->

    $scope.back = ->
      $scope.user.email_status = null

    $scope.signIn = ->
      $scope.$emit 'processing'
      AuthService.signIn($scope.user).finally -> $scope.$emit 'doneProcessing'

    $scope.sendLoginLink = ->
      $scope.$emit 'processing'
      AuthService.sendLoginLink($scope.user).finally -> $scope.$emit 'doneProcessing'

    $scope.submit = ->
      if $scope.user.has_password
        $scope.signIn()
      else
        $scope.sendLoginLink()

    $scope.setPassword = ->
      $scope.$emit 'processing'
      AuthService.forgotPassword($scope.user).finally -> $scope.$emit 'doneProcessing'

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.submit
