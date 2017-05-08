angular.module('loomioApp').directive 'authSignupForm', ($location, AppConfig, AuthService, KeyEventService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ($scope) ->
    $scope.recaptchaKey = AppConfig.recaptchaKey
    $scope.name = $scope.user.name

    $scope.helperBot =
      constructor: {singular: 'user'}
      avatarKind: 'uploaded'
      avatarUrl:  '/img/mascot.png'

    $scope.back = ->
      $scope.user.email_status = null

    $scope.submit = ->
      $scope.$emit 'processing'
      $scope.user.name = $scope.name
      AuthService.signUp($scope.user).finally -> $scope.$emit 'doneProcessing'

    document.querySelector('.auth-signup-form__name input').focus()

    KeyEventService.submitOnEnter($scope, anyEnter: true)
