AuthService   = require 'shared/services/auth_service.coffee'
EventBus      = require 'shared/services/event_bus.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'
I18n          = require 'shared/services/i18n.coffee'

{ hardReload }    = require 'shared/helpers/window.coffee'
{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'authSigninForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ['$scope', ($scope) ->

    $scope.signIn = ->
      EventBus.emit $scope, 'processing'
      AuthService.signIn($scope.user).then ->
        hardReload()
      , ->
        $scope.user.errors = if $scope.user.hasToken
          { token:    [I18n.t('auth_form.invalid_token')] }
        else
          { password: [I18n.t('auth_form.invalid_password')] }
        EventBus.emit $scope, 'doneProcessing'

    $scope.signInAndSetPassword = ->
      LmoUrlService.params('set_password', true)
      $scope.signIn()

    $scope.sendLoginLink = ->
      EventBus.emit $scope, 'processing'
      AuthService.sendLoginLink($scope.user).finally -> EventBus.emit $scope, 'doneProcessing'

    $scope.submit = ->
      if $scope.user.hasPassword or $scope.user.hasToken
        $scope.signIn()
      else
        $scope.sendLoginLink()

    submitOnEnter($scope, anyEnter: true)
    EventBus.emit $scope, 'focus'
  ]
