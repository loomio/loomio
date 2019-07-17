<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { capitalize } from 'lodash'

export default
  props:
    user: Object

  methods:
    capitalize: capitalize

    select: (provider) ->
      # EventBus.emit $scope, 'processing'
      window.location = "#{provider.href}?back_to=#{window.location.href}"

    iconClass: (provider) ->
      "mdi-" + if (provider == 'saml') then 'key-variant' else provider

    providerColor: (provider) ->
      switch provider
        when 'facebook' then '#3b5998'
        when 'google' then '#dd4b39'
        when 'slack' then '#e9a820'
        when 'saml' then @$vuetify.theme.themes.light.primary

  computed:
    emailLogin: -> AppConfig.features.app.email_login
    providers: -> AppConfig.identityProviders.filter (provider) -> provider.name != 'slack'
</script>

<template lang="pug">
.auth-provider-form(v-if='providers.length')
  v-layout.auth-provider-form__providers(column)
    v-btn.auth-provider-form__provider.my-1(v-for='provider in providers' :key="provider.id" outlined :color="providerColor(provider.name)" @click='select(provider)')
      v-icon {{ iconClass(provider.name) }}
      space
      span(v-t="{ path: 'auth_form.continue_with_provider', args: { provider: capitalize(provider.name) } }")
    p.my-2.text-xs-center.auth-email-form__or-enter-email(v-if='emailLogin', v-t="'auth_form.or_enter_your_email'")
</template>

<style lang="sass">
.auth-provider-form__providers
  max-width: 256px
  margin: 0 auto

.auth-provider-form__provider

</style>
