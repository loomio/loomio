<script lang="coffee">
export default
  props:
  data: ->
  methods:
</script>
<template lang="pug">
.auth-form.lmo-slide-animation
  .lmo-disabled-form(ng-show='isDisabled')
  .auth-form__logging-in.animated(ng-if='!loginComplete()')
    .auth-form__email-not-set.animated(ng-if='!user.emailStatus')
      auth_provider_form(user='user')
      auth_email_form(user='user', ng-if='emailLogin')
      .auth-form__privacy-notice.md-caption.lmo-hint-text(ng-if='privacyUrl', translate='auth_form.privacy_notice', translate-values='{siteName: siteName, privacyUrl: privacyUrl}')
    .auth-form__email-set.animated(ng-if='user.emailStatus')
      auth_identity_form.animated(ng-if='pendingProviderIdentity && !user.createAccount', user='user', identity='pendingProviderIdentity')
      .auth-form__no-pending-identity.animated(ng-switch='user.authForm', ng-if='!pendingProviderIdentity || user.createAccount')
        auth_signin_form.animated(ng-switch-when='signIn', user='user')
        auth_signup_form.animated(ng-switch-when='signUp', user='user')
        auth_inactive_form.animated(ng-switch-when='inactive', user='user')
  auth_complete.animated(ng-if='loginComplete()', user='user')
</template>
<style lang="scss">
</style>

<!-- { listenForLoading }    = require 'shared/helpers/listen'
{ getProviderIdentity } = require 'shared/helpers/user'
AppConfig               = require 'shared/services/app_config'


angular.module('loomioApp').directive 'authForm', ->
  scope: {preventClose: '=', user: '='}
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ['$scope', ($scope) ->
    $scope.emailLogin = AppConfig.features.app.email_login
    $scope.siteName = AppConfig.theme.site_name
    $scope.privacyUrl = AppConfig.theme.privacy_url

    $scope.loginComplete = ->
      $scope.user.sentLoginLink or $scope.user.sentPasswordLink

    $scope.pendingProviderIdentity = getProviderIdentity()

    listenForLoading $scope
  ] -->
