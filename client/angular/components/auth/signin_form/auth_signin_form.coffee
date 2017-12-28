AuthService = require 'shared/services/auth_service.coffee'
I18n        = require 'shared/services/i18n.coffee'

{ hardReload }    = require 'shared/helpers/window.coffee'
{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'authSigninForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ($scope) ->

    $scope.signIn = ->
      $scope.$emit 'processing'
      AuthService.signIn($scope.user).then ->
        hardReload()
      , ->
        $scope.user.errors = if $scope.user.hasToken
          { token:    [I18n.t('auth_form.invalid_token')] }
        else
          { password: [I18n.t('auth_form.invalid_password')] }
        $scope.$emit 'doneProcessing'

    $scope.sendLoginLink = ->
      $scope.$emit 'processing'
      AuthService.sendLoginLink($scope.user).finally -> $scope.$emit 'doneProcessing'

    $scope.submit = ->
      if $scope.user.hasPassword or $scope.user.hasToken
        $scope.signIn()
      else
        $scope.sendLoginLink()

    submitOnEnter($scope, anyEnter: true)
    $scope.$emit 'focus'
