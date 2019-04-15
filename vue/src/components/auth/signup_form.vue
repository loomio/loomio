<script lang="coffee">
export default
  props:
  data: ->
  methods:
</script>
<template lang="pug">
.auth-signup-form(ng-if='!allow()')
  h2.lmo-h2(translate='auth_form.invitation_required')
.auth-signup-form(ng-if='allow()')
  .auth-signup-form__welcome
    auth_avatar(user='user')
    h2.lmo-h2(translate='auth_form.welcome', translate-value-site-name='{{vars.site_name}}')
    p(translate='auth_form.sign_up_helptext')
  md-input-container.md-block.auth-signup-form__name
    label(translate='auth_form.name')
    input.lmo-primary-form-input(type='text', md-autofocus='true', placeholder='{{auth_form.name_placeholder | translate}}', ng-model='vars.name', ng-required='true')
    validation_errors(subject='user', field='name')
  .auth-signup-form__consent(ng-if='termsUrl')
    md-checkbox.auth-signup-form__legal-accepted(ng-model='vars.legalAccepted')
    span(translate='auth_form.i_accept', translate-values='{termsUrl: termsUrl, privacyUrl: privacyUrl}')
    validation_errors(subject='user', field='legalAccepted')
  md-button.md-primary.md-raised.auth-signup-form__submit(ng-disabled='!vars.name || (termsUrl &&!vars.legalAccepted)', translate='auth_form.create_account', ng-click='submit()')
  div(vc-recaptcha='true', size='invisible', key='recaptchaKey', ng-if='useRecaptcha()', on-success='submitForm(response)')
</template>
<style lang="scss">
</style>


<!-- AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'
AuthService = require 'shared/services/auth_service'
I18n        = require 'shared/services/i18n'

{ hardReload }    = require 'shared/helpers/window'
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

    $scope.useRecaptcha = -> $scope.recaptchaKey && !$scope.user.hasToken

    $scope.submit = ->
      if $scope.useRecaptcha()
        grecaptcha.execute()
      else
        $scope.submitForm()

    $scope.submitForm = (recaptcha) ->
      $scope.user.recaptcha = recaptcha
      if AuthService.validSignup($scope.vars, $scope.user)
        EventBus.emit $scope, 'processing'
        AuthService.signUp($scope.user, hardReload).finally ->
          EventBus.emit $scope, 'doneProcessing'

    submitOnEnter($scope, anyEnter: true)
    EventBus.emit $scope, 'focus'
  ] -->
