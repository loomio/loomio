AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'
AuthService = require 'shared/services/auth_service'
I18n        = require 'shared/services/i18n'

{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'authSignupForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ['$scope', ($scope) ->
    $scope.recaptchaKey = AppConfig.recaptchaKey
    $scope.termsUrl     = AppConfig.theme.terms_url
    $scope.privacyUrl   = AppConfig.theme.privacy_url
    $scope.name         = $scope.user.name
    $scope.vars         = {name: $scope.name, site_name: AppConfig.theme.site_name}
    $scope.allow        = ->
      AppConfig.features.app.create_user or AppConfig.pendingIdentity.identity_type?

    $scope.submit = ->
      # prevent submit on enter if legal not accepted
      return if $scope.termsUrl && !$scope.vars.legalAccepted

      if $scope.vars.name
        $scope.user.errors = {}
        EventBus.emit $scope, 'processing'
        $scope.user.name           = $scope.vars.name
        $scope.user.legalAccepted  = $scope.vars.legalAccepted
        AuthService.signUp($scope.user).finally -> EventBus.emit $scope, 'doneProcessing'
      else
        $scope.user.errors =
          name: [I18n.t('auth_form.name_required')]

    submitOnEnter($scope, anyEnter: true)
    EventBus.emit $scope, 'focus'
  ]
