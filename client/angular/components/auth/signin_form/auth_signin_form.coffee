AuthService = require 'shared/services/auth_service.coffee'

{ hardReload } = require 'angular/helpers/window.coffee'

angular.module('loomioApp').directive 'authSigninForm', ($translate, KeyEventService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ($scope) ->

    $scope.signIn = ->
      $scope.$emit 'processing'
      AuthService.signIn($scope.user).then ->
        hardReload()
      , ->
        $scope.user.errors = if $scope.user.hasToken
          { token:    [$translate.instant('auth_form.invalid_token')] }
        else
          { password: [$translate.instant('auth_form.invalid_password')] }
        $scope.$emit 'doneProcessing'

    $scope.sendLoginLink = ->
      $scope.$emit 'processing'
      AuthService.sendLoginLink($scope.user).finally -> $scope.$emit 'doneProcessing'

    $scope.submit = ->
      if $scope.user.hasPassword or $scope.user.hasToken
        $scope.signIn()
      else
        $scope.sendLoginLink()

    KeyEventService.submitOnEnter($scope, anyEnter: true)
    $scope.$emit 'focus'
