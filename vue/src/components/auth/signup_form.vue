<script lang="js">
import EventBus    from '@/shared/services/event_bus';
import AuthService from '@/shared/services/auth_service';
import AppConfig from '@/shared/services/app_config';
import TurnstileWidget from '@/components/auth/turnstile_widget.vue';

export default {
  components: { TurnstileWidget },
  props: {
    user: Object
  },

  mounted() {
    EventBus.$emit('set-auth-modal-title', "auth_form.create_account");
  },

  data() {
    return {
      siteName: AppConfig.theme.site_name,
      turnstileSiteKey: AppConfig.turnstileSiteKey,
      turnstileToken: '',
      vars: {email: this.user.email, site_name: AppConfig.theme.site_name},
      loading: false
    };
  },

  computed: {
    allow() {
      return AppConfig.features.app.create_user || (AppConfig.pendingIdentity.identity_type != null);
    },
    submitBlockedByCaptcha() {
      return Boolean(this.turnstileSiteKey) && !this.turnstileToken;
    }
  },

  methods: {
    submit() {
      if (this.submitBlockedByCaptcha) { return; }
      if (AuthService.validSignup(this.vars, this.user)) {
        this.user.turnstileToken = this.turnstileToken;
        this.loading = true;
        AuthService.signUp(this.user).finally(() => {this.loading = false; });
      }
    },
  }
};

</script>
<template lang="pug">
v-card.auth-signup-form(
  :title="allow ? $t('auth_form.welcome', { siteName: siteName }) : $t('auth_form.invitation_required')")
  template(v-slot:append)
    auth-back-button(@click='user.authForm = null')
  form(v-if="allow" @submit.prevent="submit" novalidate)
    v-sheet.mx-4
      .max-width-400.mx-auto
        v-text-field.auth-signup-form__email(
          id="new-account-email"
          type="email"
          name="email"
          autocomplete="email"
          :label="$t('common.email_address')"
          variant="outlined"
          v-model="vars.email"
          required)
        validation-errors(:subject='user' field='email')
        turnstile-widget(v-model='turnstileToken')

    v-card-actions.mt-8
      v-spacer
      v-btn.auth-signup-form__submit(
        type="submit"
        variant="elevated"
        color="primary"
        :loading="loading"
        :disabled='!vars.email || submitBlockedByCaptcha')
        span(v-t="'auth_form.create_account'")
</template>
<style>
.auth-signup-form .v-label {
  opacity: var(--v-high-emphasis-opacity);
}
</style>
