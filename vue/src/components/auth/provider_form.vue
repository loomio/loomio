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
      return "mdi-" + ((['saml', 'oauth'].includes(provider)) ? 'key-variant' : provider);
    },

    providerColor(provider) {
      switch (provider) {
      case 'facebook': return '#3b5998';
      case 'google': return '#dd4b39';
      case 'slack': return '#e9a820';
      case 'saml': return 'primary';
      case 'oauth': return 'primary';
      }
    },
    providerName(name) {
      if (AppConfig.theme.saml_login_provider_name && name == 'saml'){
        return AppConfig.theme.saml_login_provider_name;
      } else if (AppConfig.theme.oauth_login_provider_name && name == 'oauth'){
        return AppConfig.theme.oauth_login_provider_name;
      } else {
        return capitalize(name);
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
  .d-flex.flex-column.auth-provider-form__providers
    v-btn.auth-provider-form__provider.my-2(
      v-for='provider in providers'
      :key="provider.id"
      variant="tonal"
      :color="providerColor(provider.name)"
      @click='select(provider)'
    )
      common-icon(:color="providerColor(provider.name)" :name="iconClass(provider.name)")
      space
      span(v-t="{ path: 'auth_form.continue_with_provider', args: { provider: providerName(provider.name) } }")
    p.my-2.text-center.auth-email-form__or-enter-email(v-if='emailLogin', v-t="'auth_form.or_enter_your_email'")
</template>

<style lang="sass">
.auth-provider-form__providers
  max-width: 400px
  margin: 0 auto

</style>
