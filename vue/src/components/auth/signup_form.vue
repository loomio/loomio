<script lang="coffee">
import EventBus    from '@/shared/services/event_bus'
import AuthService from '@/shared/services/auth_service'
import AppConfig from '@/shared/services/app_config'

export default
  props:
    user: Object
  data: ->
  methods:
    submit: ->
      if @useRecaptcha
        grecaptcha.execute()
      else
        @submitForm()

    submitForm: (recaptcha) ->
      @user.recaptcha = recaptcha
      if AuthService.validSignup(@vars, @user)
        # EventBus.emit $scope, 'processing'
        AuthService.signUp(@user, hardReload).finally ->
          # EventBus.emit $scope, 'doneProcessing'
  computed:
    recaptchaKey: -> AppConfig.recaptchaKey
    termsUrl:     -> AppConfig.theme.terms_url
    privacyUrl:   -> AppConfig.theme.privacy_url
    name:         -> @user.name
    vars:         -> {name: @name, site_name: AppConfig.theme.site_name}
    allow:        ->
      AppConfig.features.app.create_user or AppConfig.pendingIdentity.identity_type?
    useRecaptcha: -> @recaptchaKey && !@user.hasToken

</script>
<template lang="pug">
.auth-signup-form(v-if='!allow()')
  h2.lmo-h2(v-t="'auth_form.invitation_required'")
.auth-signup-form(v-if='allow()')
  .auth-signup-form__welcome
    //- auth_avatar(user='user')
    h2.lmo-h2(v-t="{ path: 'auth_form.welcome', args: { site_name: vars.site_name } }")
    p(v-t="'auth_form.sign_up_helptext'")
  .md-block.auth-signup-form__name
    label(v-t="'auth_form.name'")
    v-text-field.lmo-primary-form-input(type='text', md-autofocus='true', :placeholder="'auth_form.name_placeholder'" v-model='vars.name', required='true')
    //- validation_errors(subject='user', field='name')
  .auth-signup-form__consent(v-if='termsUrl')
    v-checkbox.auth-signup-form__legal-accepted(v-model='vars.legalAccepted')
    span(v-t="{ path: 'auth_form.i_accept', args: { termsUrl: termsUrl, privacyUrl: privacyUrl }}")
    //- validation_errors(subject='user', field='legalAccepted')
  md-button.md-primary.md-raised.auth-signup-form__submit(:disabled='!vars.name || (termsUrl && !vars.legalAccepted)', v-t="'auth_form.create_account'", @click='submit()')
  div(vc-recaptcha='true', size='invisible', key='recaptchaKey', v-if='useRecaptcha()', on-success='submitForm(response)')
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
