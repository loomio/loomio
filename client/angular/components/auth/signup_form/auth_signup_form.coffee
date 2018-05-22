AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'
AuthService = require 'shared/services/auth_service'
I18n        = require 'shared/services/i18n'

{ hardReload }    = require 'shared/helpers/window'
{ submitOnEnter } = require 'shared/helpers/keyboard'

validSignup = (vars, user) ->
  user.errors = {}

  if !vars.name
    user.errors.name = [I18n.t('auth_form.name_required')]

  if AppConfig.theme.terms_url && !vars.legalAccepted
    user.errors.legalAccepted = [I18n.t('auth_form.terms_required')]

  if _.keys(user.errors)
    user.name           = vars.name
    user.legalAccepted  = vars.legalAccepted

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

    $scope.useRecaptcha = -> $scope.recaptchaKey && !$scope.user.hasToken

    $scope.submit = ->
      if $scope.useRecaptcha()
        grecaptcha.execute()
      else
        $scope.submitForm()

    $scope.submitForm = ->
      if validSignup($scope.vars, $scope.user)
        EventBus.emit $scope, 'processing'
        AuthService.signUpOrIn($scope.user).finally ->
          EventBus.emit $scope, 'doneProcessing'

    submitOnEnter($scope, anyEnter: true)
    EventBus.emit $scope, 'focus'
  ]
