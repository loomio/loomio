AppConfig   = require 'shared/services/app_config.coffee'
AuthService = require 'shared/services/auth_service.coffee'
I18n        = require 'shared/services/i18n.coffee'

{ hardReload }    = require 'angular/helpers/window.coffee'
{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'authIdentityForm', ->
  scope: {user: '=', identity: '='}
  templateUrl: 'generated/components/auth/identity_form/auth_identity_form.html'
  controller: ($scope) ->
    $scope.siteName = AppConfig.theme.site_name
    $scope.createAccount = ->
      $scope.$emit 'processing'
      AuthService.confirmOauth().then ->
        hardReload()
      , ->
        $scope.$emit 'doneProcessing'

    $scope.submit = ->
      $scope.$emit 'processing'
      $scope.user.email = $scope.email
      AuthService.sendLoginLink($scope.user).then (->), ->
        $scope.user.errors = {email: [I18n.t('auth_form.email_not_found')]}
      .finally ->
        $scope.$emit 'doneProcessing'

    submitOnEnter $scope, anyEnter: true
