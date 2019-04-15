<script lang="coffee">
export default
  props:
  data: ->
  methods:
</script>
<template lang="pug">
.auth-identity-form
  h2.lmo-h2(translate='auth_form.hello', translate-value-name='{{user.name || user.email}}')
  auth_avatar(user='user')
  .auth-identity-form__options
    .auth-identity-form__new-account
      p(translate='auth_form.new_to_loomio', translate-values='{site_name: siteName}')
      md-button.md-primary.md-raised(ng-click='createAccount()', translate='auth_form.create_account')
    .auth-identity-form__existing-account
      p(translate='auth_form.already_a_user', translate-values='{site_name: siteName}')
      md-input-container.md-block.auth-email-form__email
        label(translate='auth_form.email')
        input#email.lmo-primary-form-input(name='email', type='text', md-autofocus='true', placeholder="{{ \'auth_form.email_placeholder\' | translate}}", ng-model='email')
        validation_errors(subject='user', field='email')
      md-button(ng-click='submit()', translate='auth_form.link_accounts')
</template>
<style lang="scss">
</style>

<!-- AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'
AuthService = require 'shared/services/auth_service'
I18n        = require 'shared/services/i18n'

{ hardReload }    = require 'shared/helpers/window'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'authIdentityForm', ->
  scope: {user: '=', identity: '='}
  templateUrl: 'generated/components/auth/identity_form/auth_identity_form.html'
  controller: ['$scope', ($scope) ->
    $scope.siteName = AppConfig.theme.site_name
    $scope.createAccount = -> $scope.user.createAccount = true

    $scope.submit = ->
      EventBus.emit $scope, 'processing'
      $scope.user.email = $scope.email
      AuthService.sendLoginLink($scope.user).then (->), ->
        $scope.user.errors = {email: [I18n.t('auth_form.email_not_found')]}
      .finally ->
        EventBus.emit $scope, 'doneProcessing'

    submitOnEnter $scope, anyEnter: true
  ] -->
