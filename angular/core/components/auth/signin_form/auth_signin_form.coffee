angular.module('loomioApp').directive 'authSigninForm', ($timeout, $translate, Session, AuthService, KeyEventService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ($scope) ->

    $scope.back = ->
      $scope.user.email_status = null

    $scope.signIn = ->
      $scope.$emit 'processing'
      AuthService.signIn($scope.user).then (response) ->
        Session.login(response)
        FlashService.success 'auth_form.signed_in'
        $scope.$emit 'signedIn'
      , ->
        $scope.user.errors = {password: [$translate.instant('auth_form.invalid_password')] }
        $scope.$emit 'doneProcessing'

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

    if $scope.user.has_password
      $timeout -> document.querySelector('.auth-signin-form__password input').focus()

    KeyEventService.submitOnEnter($scope, anyEnter: true)
