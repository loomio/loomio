<script lang="js">
import EventBus    from '@/shared/services/event_bus';
import AuthService from '@/shared/services/auth_service';
import AppConfig from '@/shared/services/app_config';

export default {
  props: {
    user: Object,
    identity: Object
  },

  data() {
    return {
      loading: false,
      email: ''
    };
  },

  methods: {
    submit() {
      this.loading = true;
      this.user.email = this.email;
      AuthService.sendLoginLink(this.user).then((() => {}), () => {
        return this.user.errors = {email: [this.$t('auth_form.email_not_found')]};
      })
      .finally(() => {
        this.loading = false;
      });
    },
    createAccount() {
      this.user.createAccount = true;
      this.user.authForm = 'signUp';
    }
  },
  computed: {
    siteName() { return AppConfig.theme.site_name; }
  }
}

</script>
<template lang="pug">
v-card.auth-identity-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()")
  v-card-title
    h1.text-h5(tabindex="-1" role="status" aria-live="polite"  v-t="{ path: 'auth_form.hello', args: { name: user.name || user.email } }")
    v-spacer
    v-btn.back-button(icon :title="$t('common.action.back')" @click='user.authForm = null')
      common-icon(name="mdi-close")
  v-sheet.mx-4.pb-4
    .mb-4.text-center
      v-layout(justify-center)
        user-avatar(:user='user')
    .mb-4.text-center
    .auth-identity-form__options
      .auth-identity-form__new-account.mb-8
        p.text-center(v-t="{ path: 'auth_form.new_to_loomio', args: { site_name: siteName } }")
        v-layout(justify-center)
          v-btn(color="primary" @click='createAccount()' v-t="'auth_form.create_account'" :disabled="email.length > 0")
      .auth-identity-form__existing-account
        .auth-email-form__email
          p.text-center(v-t="'auth_form.already_a_user'")
          v-text-field#email(name='email' type='text' :placeholder="$t('auth_form.email_address_of_existing_account')" v-model='email')
          validation-errors(:subject='user' :field='email')
        v-layout(justify-center)
          v-btn(color="primary" @click='submit()' v-t="'auth_form.link_accounts'" :loading="loading" :disabled="email.length == 0")
</template>
