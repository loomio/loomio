<script lang="js">
import AppConfig from '@/shared/services/app_config';
import { capitalize } from 'lodash-es';

export default {
  props: {
    user: Object
  },

  methods: {
    capitalize,

    select(provider) {
      window.location = `${provider.href}?back_to=${window.location.href}`;
    },

    iconClass(provider) {
      return "mdi-" + ((provider === 'saml') ? 'key-variant' : provider);
    },

    providerColor(provider) {
      switch (provider) {
      case 'facebook': return '#3b5998';
      case 'google': return '#dd4b39';
      case 'slack': return '#e9a820';
      case 'saml': return this.$vuetify.theme.themes.light.primary;
      }
    }
  },

  computed: {
    emailLogin() { return AppConfig.features.app.email_login; },
    providers() { return AppConfig.identityProviders.filter(provider => provider.name !== 'slack'); }
  }
}
</script>

<template lang="pug">
.auth-provider-form(v-if='providers.length')
  v-layout.auth-provider-form__providers(column)
    v-btn.auth-provider-form__provider.my-2(v-for='provider in providers' :key="provider.id" outlined :color="providerColor(provider.name)" @click='select(provider)')
      common-icon(:name="iconClass(provider.name)")
      space
      span(v-t="{ path: 'auth_form.continue_with_provider', args: { provider: capitalize(provider.name) } }")
    p.my-2.text-center.auth-email-form__or-enter-email(v-if='emailLogin', v-t="'auth_form.or_enter_your_email'")
</template>

<style lang="sass">
.auth-provider-form__providers
  max-width: 256px
  margin: 0 auto

</style>
