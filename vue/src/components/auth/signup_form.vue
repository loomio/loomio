<script lang="js">
import EventBus    from '@/shared/services/event_bus';
import AuthService from '@/shared/services/auth_service';
import AppConfig from '@/shared/services/app_config';

export default {
  props: {
    user: Object
  },

  mounted() {
    EventBus.$emit('set-auth-modal-title', "auth_form.create_account");
  },

  data() {
    return {
      siteName: AppConfig.theme.site_name,
      vars: {name: this.user.name, site_name: AppConfig.theme.site_name},
      loading: false
    };
  },

  methods: {
    submit() {
      if (AuthService.validSignup(this.vars, this.user)) {
        this.loading = true;
        AuthService.signUp(this.user).finally(() => {this.loading = false; });
      }
    },
  },
  computed: {
    termsUrl() { return AppConfig.theme.terms_url; },
    privacyUrl() { return AppConfig.theme.privacy_url; },
    newsletterEnabled() { return AppConfig.newsletterEnabled; },
    allow() {
      return AppConfig.features.app.create_user || (AppConfig.pendingIdentity.identity_type != null);
    },
  }
};

</script>
<template lang="pug">
v-card.auth-signup-form(
  :title="allow ? $t('auth_form.welcome', { siteName: siteName }) : $t('auth_form.invitation_required')"
  @keyup.ctrl.enter="submit()"
  @keydown.meta.enter.stop.capture="submit()"
  @keydown.enter="submit()")
  template(v-slot:append)
    v-btn.back-button(icon variant="text" :title="$t('common.action.back')" @click='user.authForm = null')
      common-icon(name="mdi-close")
  v-sheet.mx-4(v-if="allow")
    .auth-signup-form__welcome.text-center.my-2
      p(v-t="{path: 'auth_form.sign_up_as', args: {email: user.email}}")
    .auth-signup-form__name
      v-text-field(
        type='text'
        :label="$t('auth_form.name_placeholder')"
        :placeholder="$t('auth_form.enter_your_name')"
        variant="outlined"
        v-model='vars.name'
        required='true')
      validation-errors(:subject='user' field='legalAccepted')
      validation-errors(:subject='user' field='email')
    .auth-signup-form__consent(v-if='termsUrl')
      v-checkbox.auth-signup-form__legal-accepted(v-model='vars.legalAccepted' hide-details)
        template(v-slot:label)
          i18n-t(keypath="auth_form.i_accept_all" tag="span")
            template(v-slot:termsLink)
              a(:href='termsUrl' target='_blank' @click.stop v-t="'powered_by.terms_of_service'")
            template(v-slot:privacyLink)
              a(:href='privacyUrl' target='_blank' @click.stop v-t="'powered_by.privacy_policy'")
    .auth-signup-form__newsletter(v-if='newsletterEnabled')
      v-checkbox.auth-signup-form__newsletter-accepted(v-model='vars.emailNewsletter' hide-details)
        template(v-slot:label)
          i18n-t(keypath="auth_form.newsletter_label" tag="span")
            template(v-slot:link)
              //- a(href='https://help.loomio.org/en/newsletter/' target='_blank' @click.stop v-t="'email_settings_page.email_newsletter'")
              span(v-t="'email_settings_page.email_newsletter'")

  v-card-actions.mt-8(v-if="allow")
    v-spacer
    v-btn.auth-signup-form__submit(
      variant="elevated"
      color="primary"
      :loading="loading"
      :disabled='!vars.name || (termsUrl && !vars.legalAccepted)'
    )
      span(v-t="'auth_form.create_account'" @click='submit()')
</template>
<style>
.auth-signup-form .v-label {
  opacity: var(--v-high-emphasis-opacity);
}
</style>
