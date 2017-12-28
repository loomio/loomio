AppConfig   = require 'shared/services/app_config.coffee'
AuthService = require 'shared/services/auth_service.coffee'
I18n        = require 'shared/services/i18n.coffee'

{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'authSignupForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ($scope) ->
    $scope.vars         = {}
    $scope.recaptchaKey = AppConfig.recaptchaKey
    $scope.name         = $scope.user.name
    $scope.allow        = ->
      AppConfig.features.app.create_user or AppConfig.pendingIdentity

    $scope.submit = ->
      if $scope.vars.name
        $scope.user.errors = {}
        $scope.$emit 'processing'
        $scope.user.name  = $scope.vars.name
        AuthService.signUp($scope.user).finally -> $scope.$emit 'doneProcessing'
      else
        $scope.user.errors =
          name: [I18n.t('auth_form.name_required')]

    submitOnEnter($scope, anyEnter: true)
    $scope.$emit 'focus'
