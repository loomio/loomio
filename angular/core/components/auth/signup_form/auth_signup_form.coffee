angular.module('loomioApp').directive 'authSignupForm', (AppConfig, AuthService, KeyEventService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ($scope) ->
    $scope.recaptchaKey = AppConfig.recaptchaKey
    $scope.name         = $scope.user.name

    $scope.submit = ->
      $scope.$emit 'processing'
      $scope.user.name  = $scope.name
      AuthService.signUp($scope.user).finally -> $scope.$emit 'doneProcessing'

    KeyEventService.submitOnEnter($scope, anyEnter: true)
    $scope.$emit 'focus'
