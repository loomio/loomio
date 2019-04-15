<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import _capitalize from 'lodash/capitalize'
import _reject from 'lodash/reject'

export default
  props:
    user: Object
  # data: ->
  methods:
    select: (provider) ->
      # EventBus.emit $scope, 'processing'
      $window.location = "#{provider.href}?back_to=#{$window.location.href}"
  computed:
    iconClass: ->
      "mdi-" + (provider.name == 'saml') ? 'key-variant' : provider.name
    buttonClass: ->
      (provider.name == 'saml') ? 'md-primary' : provider.name
    emailLogin: -> AppConfig.features.app.email_login
    providers: -> _reject AppConfig.identityProviders, (provider) -> provider.name == 'slack'
</script>
<template lang="pug">
.auth-provider-form(v-if='providers.length')
  .auth-provider-form__providers
    v-btn.md-button.md-raised(type='button', :class="buttonClass", @click='select(provider)', v-for='provider in providers' :key="provider.id")
      i.mdi.mdi-24px(:class="iconClass")
      span(v-t="{ path: 'auth_form.continue_with_provider', args: { provider: _capitalize(provider.name) } }")
      span
    p.md-subhead.auth-email-form__or-enter-email(v-if='emailLogin', v-t="'auth_form.or_enter_your_email'")
</template>
<style lang="scss">
</style>
