<script lang="js">
import Records       from '@/shared/services/records';
import AuthModalMixin from '@/mixins/auth_modal';
import AuthService from '@/shared/services/auth_service';
import AppConfig from '@/shared/services/app_config';
import { useI18n } from 'vue-i18n';

export default {
  mixins: [AuthModalMixin],
  props: {
    user: Object
  },
  setup() {
    const { t } = useI18n();
    return { t };
  },
  data() {
    return {
      attempts: 0,
      loading: false,
      revealEmailAccountStatus: AppConfig.features.app.reveal_email_account_status
    };
  },
  methods: {
    submit() {
      this.loading = true;
      AuthService.signIn(this.user).finally(() => {
        this.attempts += 1;
        this.loading = false;
      });
    },
    back() {
      this.user.code = null;
      this.user.errors = {};
      this.user.sentLoginLink = false;
      this.user.createAccount = false;
      this.user.authForm = null;
    }
  }
};
</script>
<template lang="pug">
v-card.auth-complete(
  :title="$t('auth_form.check_your_email')"
  v-submit-on-mod-enter="submit"
  @keydown.enter.exact="submit()")
  template(v-slot:append)
    auth-back-button(@click="back")
  v-sheet.mx-4.text-center
    p.my-6(v-if='user.sentLoginLink')
      span(v-if='user.createAccount') {{ t('auth_form.login_link_sent', { email: user.email }) }}
      span(v-else-if='revealEmailAccountStatus' v-t="{ path: 'auth_form.login_link_sent', args: { email: user.email }}")
      span(v-else v-t="{ path: 'auth_form.login_link_sent_if_account_exists_sentence', args: { email: user.email }}")
      br
      span(v-t="'auth_form.instructions_code'", v-if='attempts < 3')
    .lmo-validation-error(v-t="'auth_form.too_many_attempts'", v-if='attempts >= 3')
    .auth-complete__code-input.mb-4(v-if='user.sentLoginLink && attempts < 3')
      .auth-complete__code.mx-auto(style="max-width: 256px")
        v-text-field.text-headline-small(
          variant="outlined"
          label="Code"
          :placeholder="$t('auth_form.code')"
          type='integer'
          maxlength='6'
          v-model='user.code'
        )
        validation-errors(:subject='user' field='code')
  v-card-actions
    v-spacer
    v-btn.auth-complete__submit(
      variant="elevated"
      color="primary"
      :loading="loading"
      @click='submit()'
      :disabled='!user.code || loading')
      span {{ t(user.createAccount ? 'auth_form.continue' : 'auth_form.sign_in') }}
</template>
<style>
.auth-complete__code input {
  letter-spacing: 0.5em;
  text-align: center;
}
</style>
