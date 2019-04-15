<script lang="coffee">
export default
  props:
  data: ->
  methods:
</script>
<template lang="pug">
.auth-provider-form(ng-if='providers.length')
  .auth-provider-form__providers
    button.md-button.md-raised(type='button', class="{{ (provider.name == \'saml\') ? \'md-primary\' : provider.name }}", ng-click='select(provider)', ng-repeat='provider in providers')
      i.mdi.mdi-24px(class="mdi-{{(provider.name == \'saml\') ? \'key-variant\' : provider.name}}")
      span(translate='auth_form.continue_with_provider', translate-value-provider='{{capitalize(provider.name)}}')
      span
    p.md-subhead.auth-email-form__or-enter-email(ng-if='emailLogin', translate='auth_form.or_enter_your_email')
</template>
<style lang="scss">
</style>

<!-- AppConfig = require 'shared/services/app_config'
EventBus  = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'authProviderForm', ['$window', ($window) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/provider_form/auth_provider_form.html'
  controller: ['$scope', ($scope) ->
    $scope.emailLogin = AppConfig.features.app.email_login
    $scope.providers = _.reject AppConfig.identityProviders, (provider) -> provider.name == 'slack'
    console.log $scope.providers
    $scope.capitalize = _.capitalize

    $scope.select = (provider) ->
      EventBus.emit $scope, 'processing'
      $window.location = "#{provider.href}?back_to=#{$window.location.href}"
  ]
] -->
