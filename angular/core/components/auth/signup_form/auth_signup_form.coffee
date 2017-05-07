angular.module('loomioApp').directive 'authSignupForm', ($location, AppConfig, AuthService, KeyEventService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ($scope) ->
    $scope.user.name = $scope.name = $location.search().sign_in_name
    $location.search('sign_in_name', null)

    $scope.helperBot =
      constructor: {singular: 'user'}
      avatarKind: 'uploaded'
      avatarUrl:  '/img/mascot.png'

    $scope.back = ->
      $scope.user.email_status = null

    $scope.submit = ->
      $scope.$emit 'processing'
      AuthService.signUp($scope.user).finallyus -> $scope.$emit 'doneProcessing'


    document.querySelector('.auth-signup-form__name input').focus()

    KeyEventService.submitOnEnter($scope, anyEnter: true)
